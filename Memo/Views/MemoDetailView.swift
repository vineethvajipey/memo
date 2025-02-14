import SwiftUI
import AVKit

struct MemoDetailView: View {
    let memo: VoiceMemo
    @ObservedObject var memoStore: VoiceMemoStore
    @Environment(\.dismiss) private var dismiss
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isEditingTranscript = false
    @State private var editedTranscript: String = ""
    @State private var editedTitle: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
            
            // Content section
            if isEditingTranscript {
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .onChange(of: editedTitle) { _ in
                        autoSave()
                    }
                
                TextEditor(text: $editedTranscript)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxHeight: .infinity)
                    .onChange(of: editedTranscript) { _ in
                        autoSave()
                    }
            } else {
                Text(memo.transcript)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle(isEditingTranscript ? "Edit Memo" : memo.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditingTranscript ? "Done" : "Edit") {
                    withAnimation {
                        isEditingTranscript.toggle()
                        if !isEditingTranscript {
                            // Final save when exiting edit mode
                            autoSave()
                        }
                    }
                }
                .foregroundColor(AppTheme.primaryRed)
            }
        }
        .onAppear {
            setupAudioPlayer()
            editedTranscript = memo.transcript
            editedTitle = memo.title
        }
        .onDisappear {
            audioPlayer?.stop()
            timer?.invalidate()
        }
    }
    
    private func autoSave() {
        // Add debounce if needed
        memoStore.updateMemo(memo, title: editedTitle, transcript: editedTranscript)
    }
    
    private func setupAudioPlayer() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: memo.audioURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading audio: \(error)")
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.pause()
            timer?.invalidate()
        } else {
            audioPlayer?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                currentTime = audioPlayer?.currentTime ?? 0
                if audioPlayer?.currentTime == audioPlayer?.duration {
                    isPlaying = false
                    timer?.invalidate()
                }
            }
        }
        isPlaying.toggle()
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