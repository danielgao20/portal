import Foundation
import CoreLocation

class OpenAIService {
    
    // Singleton instance
    static let shared = OpenAIService()
    
    // OpenAI API Endpoint
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    // Securely fetch API Key from Info.plist
    private var apiKey: String? {
        guard let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String else {
            return nil
        }
        return key
    }
    
    // Generate Journaling Prompt
    func generateJournalingPrompt(environment: String, location: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        
        // Validate API Key
        guard let apiKey = apiKey else {
            completion(nil)
            return
        }
        
        // Construct the prompt
        let prompt = """
        Given the user's current environment: \(environment) and location (lat: \(location.latitude), lon: \(location.longitude)), suggest a thoughtful journaling prompt for self-reflection.
        """
        
        // OpenAI expects an array of message objects
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful assistant that generates journaling prompts based on context."],
            ["role": "user", "content": prompt]
        ]
        
        // Create the request body
        let body: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": messages,
            "max_tokens": 60,
            "temperature": 0.7
        ]
        
        
        // Serialize JSON
        guard let url = URL(string: endpoint),
              let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = httpBody

        let session = URLSession.shared
        
        var attempts = 0
        let maxRetries = 2

        func executeRequest() {
            attempts += 1
            
            let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    if attempts < maxRetries {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                            executeRequest() // Retry
                        }
                    } else {
                        completion(nil)
                    }
                    return
                }
                
                guard let data = data else {
                    completion(nil)
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        if let raw = String(data: data, encoding: .utf8) {
                            print("[OpenAIService] Error Response: \(raw)")
                        }
                        completion(nil)
                        return
                    }
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("[OpenAIService] Raw response: \(raw)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let choices = json["choices"] as? [[String: Any]],
                       let message = choices.first?["message"] as? [String: Any],
                       let content = message["content"] as? String {
                        print("[OpenAIService] Successfully parsed response!")
                        completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                    } else {
                        print("[OpenAIService] Unexpected response format")
                        completion(nil)
                    }
                } catch {
                    print("[OpenAIService] JSON decoding error: \(error)")
                    completion(nil)
                }
            }
            task.resume()
        }
        
        executeRequest()
    }
}
