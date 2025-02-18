import SwiftUI

struct AddMemoView: View {
    @ObservedObject var memoStore: DailyMemoStore
    @Binding var selectedTab: Int
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var savedTranscript = ""
    @State private var showingDetailsSheet = false
    let date: Date
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 20) {
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
                                    .id("transcript")
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
                        
                        // Continue and New Recording buttons
                        if !isRecording && !savedTranscript.isEmpty {
                            HStack(spacing: 20) {
                                Button(action: discardRecording) {
                                    Text("New Recording")
                                        .font(AppTheme.buttonFont)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                                
                                Button(action: {
                                    showingDetailsSheet = true
                                }) {
                                    Text("Continue")
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
            .navigationTitle("New Memo")
            .sheet(isPresented: $showingDetailsSheet) {
                MemoDetailsSheet(
                    transcript: savedTranscript,
                    date: date,
                    memoStore: memoStore,
                    speechRecognizer: speechRecognizer,
                    onSave: {
                        resetView()
                        selectedTab = 1
                    }
                )
            }
        }
    }
    
    private func startRecording() {
        withAnimation {
            savedTranscript = ""
            isRecording = true
            speechRecognizer.startTranscribing()
        }
    }
    
    private func stopRecording() {
        withAnimation {
            isRecording = false
            speechRecognizer.stopTranscribing()
            savedTranscript = speechRecognizer.transcript
        }
    }
    
    private func discardRecording() {
        withAnimation {
            resetView()
        }
    }
    
    private func resetView() {
        savedTranscript = ""
        speechRecognizer.resetTranscript()
    }
}

// New sheet for entering memo details after recording
struct MemoDetailsSheet: View {
    let transcript: String
    let date: Date
    let memoStore: DailyMemoStore
    let speechRecognizer: SpeechRecognizer
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var editedTranscript: String
    @State private var selectedMood: DailyMemo.Mood = .okay
    
    init(transcript: String, date: Date, memoStore: DailyMemoStore, speechRecognizer: SpeechRecognizer, onSave: @escaping () -> Void) {
        self.transcript = transcript
        self.date = date
        self.memoStore = memoStore
        self.speechRecognizer = speechRecognizer
        self.onSave = onSave
        _editedTranscript = State(initialValue: transcript)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title Section
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                        TextField("Enter title", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(AppTheme.bodyFont)
                    }
                    .padding(.horizontal)
                    
                    // Mood Section
                    VStack(alignment: .leading) {
                        Text("Mood")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                        HStack {
                            ForEach(DailyMemo.Mood.allCases, id: \.self) { mood in
                                Button(action: {
                                    selectedMood = mood
                                }) {
                                    VStack {
                                        Image(systemName: mood.icon)
                                            .foregroundColor(mood == selectedMood ? mood.color : .gray)
                                        Text(mood.rawValue)
                                            .font(AppTheme.captionFont)
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Content Section
                    VStack(alignment: .leading) {
                        Text("Content")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                        TextEditor(text: $editedTranscript)
                            .font(AppTheme.bodyFont)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(AppTheme.background)
            .navigationTitle("Memo Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryRed)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMemo()
                    }
                    .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
    }
    
    private func saveMemo() {
        Task {
            if let audioURL = await speechRecognizer.getRecordingURL() {
                await MainActor.run {
                    memoStore.addMemo(
                        title: title.isEmpty ? "Memo \(date.formatted(date: .abbreviated, time: .shortened))" : title,
                        transcript: editedTranscript,
                        audioURL: audioURL,
                        mood: selectedMood
                    )
                    dismiss()
                    onSave()
                }
            }
        }
    }
} 