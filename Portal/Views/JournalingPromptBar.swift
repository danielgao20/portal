import SwiftUI
import CoreLocation

struct JournalingPromptBar: View {
    @Binding var environment: String
    @Binding var location: CLLocationCoordinate2D
    @State private var isLoading = false
    @State private var prompt: String = ""
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            HStack(alignment: .center) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Button(action: generatePrompt) {
                        Image(systemName: "lightbulb")
                        Text("Generate Journaling Prompt")
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                Spacer()
            }
            
            // debug border to ensure it is rendering
            Text("Debug: \(prompt.isEmpty ? "No prompt generated yet." : prompt)")
                .foregroundColor(.green)
                .border(Color.green, width: 2)
                .padding(.vertical, 5)

            if !prompt.isEmpty {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(prompt)
                        .font(.body)
                        .padding(12)
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .border(Color.red, width: 2) // debug border
                }
                .frame(maxHeight: 220) // increased height to prevent clipping
                .background(Color.orange.opacity(0.2)) // debug background
            } else {
                Text("No prompt generated yet.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemBackground).opacity(0.95))
        .background(Color.green.opacity(0.08)) // debug background
        .border(Color.purple, width: 2) // overall debug border
    }
    
    private func generatePrompt() {
        isLoading = true
        OpenAIService.shared.generateJournalingPrompt(environment: environment, location: location) { result in
            DispatchQueue.main.async {
                isLoading = false
                prompt = result ?? "Failed to generate prompt."
                
                // debugging logs
                print("[JournalingPromptBar] Prompt generated: \(prompt)")
            }
        }
    }
}
