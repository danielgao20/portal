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
            if !prompt.isEmpty {
                Text(prompt)
                    .font(.body)
                    .padding(8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .background(Color(.systemBackground).opacity(0.95))
    }
    
    private func generatePrompt() {
        isLoading = true
        OpenAIService.shared.generateJournalingPrompt(environment: environment, location: location) { result in
            DispatchQueue.main.async {
                isLoading = false
                prompt = result ?? "Failed to generate prompt."
            }
        }
    }
}
