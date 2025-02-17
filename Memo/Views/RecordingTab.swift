import SwiftUI

struct RecordingTab: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @ObservedObject var memoStore: VoiceMemoStore
    @State private var isRecording = false
    @State private var title = ""
    @State private var savedTranscript = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if !isRecording && !savedTranscript.isEmpty {
                        TextField("Recording title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal)
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textColor)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    if isRecording {
                        Spacer()
                        
                        // Live transcription
                        ScrollViewReader { proxy in
                            ScrollView {
                                Text(speechRecognizer.transcript)
                                    .font(AppTheme.bodyFont)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(AppTheme.textColor)
                                    .id("transcript") // For auto-scrolling
                            }
                            .frame(maxHeight: 100)
                            .onChange(of: speechRecognizer.transcript) { oldValue, newValue in
                                withAnimation {
                                    proxy.scrollTo("transcript", anchor: .bottom)
                                }
                            }
                        }
                        
                        // Audio visualization
                        AudioVisualizerView(
                            levels: speechRecognizer.audioLevels,
                            active: isRecording
                        )
                        .frame(height: 120)
                        .padding(.horizontal)
                        
                        Spacer()
                    } else {
                        // Saved transcript view
                        ScrollView {
                            Text(savedTranscript.isEmpty ? "Tap record to start" : savedTranscript)
                                .font(AppTheme.bodyFont)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(savedTranscript.isEmpty ? AppTheme.secondaryText : AppTheme.textColor)
                        }
                        .animation(.default, value: speechRecognizer.transcript)
                    }
                    
                    Spacer()
                    
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
                                .fill(isRecording ? AppTheme.primaryRed : AppTheme.darkRed)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Circle()
                                        .stroke(AppTheme.primaryRed.opacity(0.2), lineWidth: 2)
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
                                        .font(AppTheme.buttonFont)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button(action: saveRecording) {
                                    Text("Save")
                                        .font(AppTheme.buttonFont)
                                }
                                .buttonStyle(PrimaryButtonStyle())
                            }
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 40)
                }
                .padding()
            }
            .navigationTitle("RECORD")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .foregroundColor(AppTheme.textColor)
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
            
            // Updated date formatting
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM:HH:dd:MM:yyyy"
            title = "Recording \(dateFormatter.string(from: Date()))"
        }
    }
    
    private func saveRecording() {
        Task {
            if let audioURL = await speechRecognizer.getRecordingURL() {
                // Updated date formatting for default title
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM:HH:dd:MM:yyyy"
                let defaultTitle = "Voice Memo \(dateFormatter.string(from: Date()))"
                
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
