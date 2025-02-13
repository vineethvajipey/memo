import SwiftUI

struct RecordingTab: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @ObservedObject var memoStore: VoiceMemoStore
    @State private var isRecording = false
    @State private var title = ""
    @State private var savedTranscript = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !isRecording && !savedTranscript.isEmpty {
                    // Show title input after recording
                    TextField("Recording title", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Transcription area
                ScrollView {
                    Text(isRecording ? speechRecognizer.transcript : 
                         (savedTranscript.isEmpty ? "Tap record to start" : savedTranscript))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(isRecording || !savedTranscript.isEmpty ? .primary : .gray)
                }
                .animation(.default, value: speechRecognizer.transcript)
                
                Spacer()
                
                // Audio level visualization
                if isRecording {
                    AudioVisualizerView(
                        levels: speechRecognizer.audioLevels,
                        active: isRecording
                    )
                    .frame(height: 60)
                    .padding()
                }
                
                // Bottom controls
                VStack(spacing: 16) {
                    // Record/Stop button
                    Button(action: {
                        if isRecording {
                            stopRecording()
                        } else if savedTranscript.isEmpty {
                            startRecording()
                        }
                    }) {
                        Circle()
                            .fill(isRecording ? Color.red : Color.red.opacity(0.8))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.2), lineWidth: 2)
                                    .scaleEffect(isRecording ? 1.2 : 1.0)
                                    .opacity(isRecording ? 0.5 : 1)
                            )
                            .overlay(
                                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Save and New Recording buttons
                    if !isRecording && !savedTranscript.isEmpty {
                        HStack(spacing: 20) {
                            Button(action: discardRecording) {
                                Text("New Recording")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.bordered)
                            
                            Button(action: saveRecording) {
                                Text("Save")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 40)
            }
            .padding()
            .navigationTitle("Record")
            .animation(.default, value: isRecording)
            .animation(.default, value: savedTranscript)
        }
    }
    
    private func startRecording() {
        withAnimation {
            savedTranscript = ""
            title = ""
            isRecording = true
            speechRecognizer.startTranscribing()
        }
    }
    
    private func stopRecording() {
        withAnimation {
            isRecording = false
            speechRecognizer.stopTranscribing()
            savedTranscript = speechRecognizer.transcript
            title = "Recording \(Date().formatted(date: .abbreviated, time: .shortened))"
        }
    }
    
    private func saveRecording() {
        Task {
            if let audioURL = await speechRecognizer.getRecordingURL() {
                let defaultTitle = "Voice Memo \(Date().formatted(date: .abbreviated, time: .shortened))"
                memoStore.addMemo(
                    title: title.isEmpty ? defaultTitle : title,
                    transcript: savedTranscript,
                    audioURL: audioURL
                )
                resetView()
            }
        }
    }
    
    private func discardRecording() {
        withAnimation {
            resetView()
        }
    }
    
    private func resetView() {
        title = ""
        savedTranscript = ""
        speechRecognizer.resetTranscript()
    }
}

#Preview {
    RecordingTab(memoStore: VoiceMemoStore())
} 
