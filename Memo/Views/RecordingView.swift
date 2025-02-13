import SwiftUI

struct RecordingView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @ObservedObject var memoStore: VoiceMemoStore
    @State private var isRecording = false
    @State private var title = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Memo Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Text(speechRecognizer.transcript)
                    .padding()
                    .frame(maxHeight: .infinity, alignment: .top)
                
                Button(action: {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(isRecording ? .red : .gray)
                }
                .padding()
            }
            .navigationTitle("New Voice Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecording()
                    }
                    .disabled(!isRecording && speechRecognizer.transcript.isEmpty)
                }
            }
        }
    }
    
    private func startRecording() {
        speechRecognizer.startTranscribing()
        isRecording = true
    }
    
    private func stopRecording() {
        speechRecognizer.stopTranscribing()
        isRecording = false
    }
    
    private func saveRecording() {
        Task {
            if let audioURL = await speechRecognizer.getRecordingURL() {
                memoStore.addMemo(
                    title: title.isEmpty ? "Voice Memo \(Date().formatted(date: .abbreviated, time: .shortened))" : title,
                    transcript: speechRecognizer.transcript,
                    audioURL: audioURL
                )
            }
            await MainActor.run {
                dismiss()
            }
        }
    }
}

#Preview {
    RecordingView(memoStore: VoiceMemoStore())
        .task {
            // Preview will show empty store, but that's okay for UI preview
        }
} 