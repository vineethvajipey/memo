import SwiftUI
import AVKit

struct MemoDetailView: View {
    let memo: DailyMemo
    @ObservedObject var memoStore: DailyMemoStore
    @Environment(\.dismiss) private var dismiss
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var editedTranscript: String = ""
    @State private var editedTitle: String = ""
    @State private var selectedMood: DailyMemo.Mood
    @State private var hasAudio: Bool = false
    
    init(memo: DailyMemo, memoStore: DailyMemoStore) {
        self.memo = memo
        self.memoStore = memoStore
        _selectedMood = State(initialValue: memo.mood)
        _editedTitle = State(initialValue: memo.title)
        _editedTranscript = State(initialValue: memo.transcript)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Only show audio player if there's valid audio
            if hasAudio {
                // Audio player section
                VStack(spacing: 8) {
                    Slider(value: $currentTime, in: 0...(audioPlayer?.duration ?? 0)) { editing in
                        if !editing {
                            audioPlayer?.currentTime = currentTime
                        }
                    }
                    
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(audioPlayer?.duration ?? 0))
                    }
                    .font(AppTheme.captionFont)
                    .foregroundColor(AppTheme.secondaryText)
                }
                .padding(.horizontal)
                
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(AppTheme.primaryRed)
                }
                .frame(maxWidth: .infinity)
            }
            
            // Mood selector
            HStack {
                Text("Mood:")
                    .font(AppTheme.bodyFont)
                
                ForEach(DailyMemo.Mood.allCases, id: \.self) { mood in
                    Button(action: {
                        selectedMood = mood
                        autoSave()
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
            .padding(.vertical)
            
            // Title and Transcript section
            TextField("Title", text: $editedTitle)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .font(AppTheme.bodyFont)
                .onChange(of: editedTitle) { oldValue, newValue in
                    autoSave()
                }
            
            TextEditor(text: $editedTranscript)
                .scrollContentBackground(.hidden)
                .background(AppTheme.background)
                .cornerRadius(8)
                .frame(maxHeight: .infinity)
                .font(AppTheme.bodyFont)
                .onChange(of: editedTranscript) { oldValue, newValue in
                    autoSave()
                }
        }
        .padding()
        .navigationTitle(editedTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            checkForAudio()
        }
        .onDisappear {
            cleanup()
        }
    }
    
    private func checkForAudio() {
        // Check if the audio file exists and is not empty
        if let fileSize = try? FileManager.default.attributesOfItem(atPath: memo.audioURL.path)[.size] as? Int64,
           fileSize > 0 {
            setupAudioPlayer()
            hasAudio = true
        } else {
            hasAudio = false
        }
    }
    
    private func autoSave() {
        memoStore.updateMemo(memo, 
                           title: editedTitle, 
                           transcript: editedTranscript,
                           mood: selectedMood)
    }
    
    private func setupAudioPlayer() {
        do {
            // Configure audio session for playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create and prepare audio player
            audioPlayer = try AVAudioPlayer(contentsOf: memo.audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error setting up audio playback: \(error)")
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            timer?.invalidate()
        } else {
            do {
                // Ensure audio session is active
                try AVAudioSession.sharedInstance().setActive(true)
                audioPlayer?.play()
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    currentTime = audioPlayer?.currentTime ?? 0
                    if audioPlayer?.currentTime == audioPlayer?.duration {
                        isPlaying = false
                        timer?.invalidate()
                    }
                }
            } catch {
                print("Error during playback: \(error)")
            }
        }
        isPlaying.toggle()
    }
    
    private func cleanup() {
        audioPlayer?.stop()
        timer?.invalidate()
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Error cleaning up audio session: \(error)")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationView {
        MemoDetailView(
            memo: PreviewData.sampleMemos[0],
            memoStore: PreviewData.createPreviewStore()
        )
    }
} 
