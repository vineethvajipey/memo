import SwiftUI
import AVKit

struct MemoDetailView: View {
    let memo: VoiceMemo
    @ObservedObject var memoStore: VoiceMemoStore
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isEditingTranscript = false
    @State private var editedTranscript: String = ""
    @State private var editedTitle: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if isEditingTranscript {
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                TextEditor(text: $editedTranscript)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .frame(maxHeight: 200)
            } else {
                Text(memo.transcript)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
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
                .font(.caption)
            }
            .padding()
            
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
            }
            .frame(maxWidth: .infinity)
            
            if isEditingTranscript {
                HStack {
                    Button("Cancel") {
                        cancelEdit()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    Button("Save") {
                        saveEdit()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle(memo.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditingTranscript ? "" : "Edit") {
                    startEdit()
                }
                .opacity(isEditingTranscript ? 0 : 1)
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
    
    private func startEdit() {
        withAnimation {
            isEditingTranscript = true
        }
    }
    
    private func cancelEdit() {
        withAnimation {
            isEditingTranscript = false
            editedTranscript = memo.transcript
            editedTitle = memo.title
        }
    }
    
    private func saveEdit() {
        memoStore.updateMemo(memo, title: editedTitle, transcript: editedTranscript)
        withAnimation {
            isEditingTranscript = false
        }
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