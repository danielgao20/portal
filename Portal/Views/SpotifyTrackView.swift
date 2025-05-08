import SwiftUI

struct SpotifyTrackView: View {
    @ObservedObject var auth = SpotifyAuthService.shared
    
    var body: some View {
        VStack(spacing: 24) {
            if let track = auth.currentTrack {
                VStack(spacing: 12) {
                    if let url = track.album.images.first?.url, let imgURL = URL(string: url) {
                        AsyncImage(url: imgURL) { image in
                            image.resizable().aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200, height: 200)
                    }
                    Text(track.name)
                        .font(.title2)
                        .bold()
                    Text(track.artists.map { $0.name }.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 36) {
                        Button(action: { Task { await auth.previousTrack() } }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 32))
                        }
                        Button(action: { Task { await auth.pause() } }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 32))
                        }
                        Button(action: { Task { await auth.play() } }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 32))
                        }
                        Button(action: { Task { await auth.nextTrack() } }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 32))
                        }
                    }
                    .padding(.top, 10)
                    Button("Refresh") {
                        auth.fetchCurrentlyPlaying()
                    }
                    .buttonStyle(.bordered)
                    .font(.title3)
                }
            } else if let message = auth.noTrackMessage {
                Text(message)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                if auth.accessToken != nil {
                    HStack(spacing: 16) {
                        Button("Refresh") {
                            auth.fetchCurrentlyPlaying()
                        }
                        .buttonStyle(.bordered)
                        .font(.title3)
                        Button("Log out") {
                            auth.accessToken = nil
                            auth.currentTrack = nil
                            auth.noTrackMessage = nil
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .font(.title3)
                    }
                } else {
                    Button("Login with Spotify") {
                        auth.startAuth()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                }
            } else {
                if auth.accessToken != nil {
                    Button("Log out") {
                        auth.accessToken = nil
                        auth.currentTrack = nil
                        auth.noTrackMessage = nil
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                    .font(.title2)
                } else {
                    Button("Login with Spotify") {
                        auth.startAuth()
                    }
                    .buttonStyle(.borderedProminent)
                    .font(.title2)
                }
            }
        }
        .padding()
    }
}

struct SpotifyTrackView_Previews: PreviewProvider {
    static var previews: some View {
        SpotifyTrackView()
    }
}
