import Foundation

@MainActor
class VoiceMemoStore: ObservableObject {
    @Published private(set) var memos: [VoiceMemo] = []
    private let savePath = URL.documentsDirectory.appendingPathComponent("voice_memos.json")
    
    init() {
        loadMemos()
    }
    
    func addMemo(title: String, transcript: String, audioURL: URL) {
        let memo = VoiceMemo(title: title, transcript: transcript, audioURL: audioURL)
        memos.insert(memo, at: 0)
        saveMemos()
    }
    
    func deleteMemo(_ memo: VoiceMemo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            // Delete audio file
            try? FileManager.default.removeItem(at: memo.audioURL)
            memos.remove(at: index)
            saveMemos()
        }
    }
    
    func updateMemo(_ memo: VoiceMemo, title: String? = nil, transcript: String? = nil) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            var updatedMemo = memo
            if let title = title {
                updatedMemo = VoiceMemo(
                    id: memo.id,
                    title: title,
                    transcript: memo.transcript,
                    audioURL: memo.audioURL,
                    createdAt: memo.createdAt
                )
            }
            if let transcript = transcript {
                updatedMemo = VoiceMemo(
                    id: memo.id,
                    title: updatedMemo.title,
                    transcript: transcript,
                    audioURL: memo.audioURL,
                    createdAt: memo.createdAt
                )
            }
            memos[index] = updatedMemo
            saveMemos()
        }
    }
    
    private func saveMemos() {
        do {
            let data = try JSONEncoder().encode(memos)
            try data.write(to: savePath)
        } catch {
            print("Error saving memos: \(error)")
        }
    }
    
    private func loadMemos() {
        do {
            let data = try Data(contentsOf: savePath)
            memos = try JSONDecoder().decode([VoiceMemo].self, from: data)
        } catch {
            memos = []
        }
    }
} 
