import Foundation
import AuthenticationServices
import CommonCrypto // For PKCE SHA256 hashing

class SpotifyAuthService: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = SpotifyAuthService()
    
    @Published var accessToken: String?
    @Published var currentTrack: SpotifyTrack?
    @Published var noTrackMessage: String?
    
    private let clientID = "179afbe7632a460f8b74205661759362"
    private let redirectURI = "portalapp://callback"
    private let scopes = "user-read-currently-playing"
    private var session: ASWebAuthenticationSession?
    private var codeVerifier: String?

    // MARK: PKCE helpers
    private func generateCodeVerifier() -> String {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
        return String((0..<128).map { _ in chars.randomElement()! })
    }
    private func codeChallenge(for verifier: String) -> String {
        guard let data = verifier.data(using: .ascii) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes { _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash) }
        let base64 = Data(hash).base64EncodedString()
        return base64.replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    struct SpotifyTrack: Codable {
        let name: String
        let artists: [Artist]
        let album: Album
        struct Artist: Codable { let name: String }
        struct Album: Codable { let images: [Image]; struct Image: Codable { let url: String } }
    }

    // MARK: - Playback Controls
    @MainActor
    func play() async {
        await controlPlayback(endpoint: "play")
    }
    @MainActor
    func pause() async {
        await controlPlayback(endpoint: "pause")
    }
    @MainActor
    func nextTrack() async {
        await controlPlayback(endpoint: "next")
    }
    @MainActor
    func previousTrack() async {
        await controlPlayback(endpoint: "previous")
    }
    private func controlPlayback(endpoint: String) async {
        guard let token = accessToken else {
            print("[SpotifyAuthService] No access token for playback control.")
            return
        }
        let url = URL(string: "https://api.spotify.com/v1/me/player/\(endpoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = endpoint == "play" || endpoint == "pause" ? "PUT" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("[SpotifyAuthService] Playback control (\(endpoint)) HTTP status: \(httpResponse.statusCode)")
            }
            if let raw = String(data: data, encoding: .utf8), !raw.isEmpty {
                print("[SpotifyAuthService] Playback control response: \(raw)")
            }
        } catch {
            print("[SpotifyAuthService] Playback control error (\(endpoint)): \(error)")
        }
    }

    func startAuth() {
        // Generate PKCE code verifier and challenge
        let verifier = generateCodeVerifier()
        let challenge = codeChallenge(for: verifier)
        self.codeVerifier = verifier
        let responseType = "code"
        let authURL = URL(string:
            "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=\(responseType)&redirect_uri=\(redirectURI)&scope=\(scopes)&code_challenge_method=S256&code_challenge=\(challenge)"
        )!
        print("[SpotifyAuthService] 🔄 Starting OAuth with URL: \(authURL)")
        session = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "portalapp") { [weak self] callbackURL, error in
            print("[SpotifyAuthService] OAuth callback fired. callbackURL: \(String(describing: callbackURL)), error: \(String(describing: error))")
            guard let callbackURL = callbackURL, error == nil else { return }
            print("[SpotifyAuthService] OAuth callbackURL: \(callbackURL)")
            if let code = self?.parseCode(from: callbackURL) {
                print("[SpotifyAuthService] ✅ Authorization code received: \(code)")
                self?.exchangeCodeForToken(code: code)
            } else {
                print("[SpotifyAuthService] ❌ Authorization code not found.")
            }
        }
        session?.presentationContextProvider = self
        session?.start()
    }

    func parseCode(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        return queryItems.first(where: { $0.name == "code" })?.value
    }

    func exchangeCodeForToken(code: String) {
        guard let verifier = codeVerifier else {
            print("[SpotifyAuthService] ❌ No code verifier for PKCE exchange!")
            return
        }
        let clientSecret = "64724bfa5572489cb18493e3ba9d1ee2" // NOTE: For production, never ship client secrets in app code!
        var request = URLRequest(url: URL(string: "https://accounts.spotify.com/api/token")!)
        request.httpMethod = "POST"
        let params = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret,
            "code_verifier": verifier
        ]
        request.httpBody = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("[SpotifyAuthService] ❌ Error exchanging code for token: \(error.localizedDescription)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("[SpotifyAuthService] Token exchange HTTP status: \(httpResponse.statusCode)")
            }
            guard let data = data else {
                print("[SpotifyAuthService] ❌ No data received from token exchange")
                return
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("[SpotifyAuthService] Token exchange response body: \(raw)")
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    print("[SpotifyAuthService] ✅ Access Token received: \(accessToken)")
                    DispatchQueue.main.async {
                        self?.accessToken = accessToken
                        self?.fetchCurrentlyPlaying()
                    }
                } else {
                    print("[SpotifyAuthService] ❌ Failed to parse access token.")
                }
            } catch {
                print("[SpotifyAuthService] ❌ JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // No longer needed (implicit grant removed)
    // func parseToken(from fragment: String) -> String? { ... }
    
    func fetchCurrentlyPlaying() {
        guard let token = accessToken else { return }
        var request = URLRequest(url: URL(string: "https://api.spotify.com/v1/me/player/currently-playing")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                print("[SpotifyAuthService] Network error: \(error)")
                DispatchQueue.main.async {
                    self.noTrackMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[SpotifyAuthService] No HTTP response")
                DispatchQueue.main.async {
                    self.noTrackMessage = "No HTTP response from Spotify."
                }
                return
            }
            print("[SpotifyAuthService] HTTP status code: \(httpResponse.statusCode)")
            if httpResponse.statusCode == 204 {
                print("[SpotifyAuthService] No track is currently playing.")
                DispatchQueue.main.async {
                    self.currentTrack = nil
                    self.noTrackMessage = "No track is currently playing. Open Spotify and start playing music."
                }
                return
            }
            guard let data = data else {
                print("[SpotifyAuthService] No data received.")
                DispatchQueue.main.async {
                    self.noTrackMessage = "No data received from Spotify."
                }
                return
            }
            if let raw = String(data: data, encoding: .utf8) {
                print("[SpotifyAuthService] Raw response: \(raw)")
            }
            if let track = self.parseTrack(from: data) {
                DispatchQueue.main.async {
                    self.currentTrack = track
                    self.noTrackMessage = nil
                }
            } else {
                print("[SpotifyAuthService] Failed to parse track from response.")
                DispatchQueue.main.async {
                    self.noTrackMessage = "Failed to parse track from Spotify response."
                }
            }
        }.resume()
    }
    
    func parseTrack(from data: Data) -> SpotifyTrack? {
        struct Response: Codable { let item: SpotifyTrack? }
        return try? JSONDecoder().decode(Response.self, from: data).item
    }
    
    // Required for ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Use UIWindowScene for iOS 15+ compatibility
        return UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
