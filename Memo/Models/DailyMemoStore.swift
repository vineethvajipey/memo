import Foundation

@MainActor
class DailyMemoStore: ObservableObject {
    @Published private(set) var memos: [DailyMemo] = []
    private let savePath = URL.documentsDirectory.appendingPathComponent("daily_memos.json")
    
    init() {
        loadMemos()
    }
    
    func addMemo(title: String, transcript: String, audioURL: URL, mood: DailyMemo.Mood = .okay) {
        let memo = DailyMemo(title: title, transcript: transcript, audioURL: audioURL, mood: mood)
        memos.insert(memo, at: 0)
        saveMemos()
    }
    
    func deleteMemo(_ memo: DailyMemo) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            // Delete audio file
            try? FileManager.default.removeItem(at: memo.audioURL)
            memos.remove(at: index)
            saveMemos()
        }
    }
    
    func updateMemo(_ memo: DailyMemo, title: String? = nil, transcript: String? = nil, mood: DailyMemo.Mood? = nil) {
        if let index = memos.firstIndex(where: { $0.id == memo.id }) {
            var updatedMemo = memo
            if let title = title {
                updatedMemo = DailyMemo(
                    id: memo.id,
                    title: title,
                    transcript: memo.transcript,
                    audioURL: memo.audioURL,
                    createdAt: memo.createdAt,
                    mood: memo.mood
                )
            }
            if let transcript = transcript {
                updatedMemo = DailyMemo(
                    id: memo.id,
                    title: updatedMemo.title,
                    transcript: transcript,
                    audioURL: memo.audioURL,
                    createdAt: memo.createdAt,
                    mood: memo.mood
                )
            }
            if let mood = mood {
                updatedMemo = DailyMemo(
                    id: memo.id,
                    title: updatedMemo.title,
                    transcript: updatedMemo.transcript,
                    audioURL: memo.audioURL,
                    createdAt: memo.createdAt,
                    mood: mood
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
            memos = try JSONDecoder().decode([DailyMemo].self, from: data)
        } catch {
            memos = []
        }
    }
} 