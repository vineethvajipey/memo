import Foundation
import SwiftUI

struct PreviewData {
    static let sampleMemos = [
        DailyMemo(
            title: "Meeting Notes",
            transcript: "Discuss project timeline and deliverables for Q2",
            audioURL: URL(string: "file://sample.m4a")!,
            createdAt: Date().addingTimeInterval(-3600),
            mood: .good
        ),
        DailyMemo(
            title: "Shopping List",
            transcript: "Milk, eggs, bread, and vegetables for dinner",
            audioURL: URL(string: "file://sample2.m4a")!,
            createdAt: Date().addingTimeInterval(-7200),
            mood: .great
        )
    ]
    
    @MainActor
    static func createPreviewStore() -> DailyMemoStore {
        let store = DailyMemoStore()
        for memo in sampleMemos {
            store.addMemo(
                title: memo.title,
                transcript: memo.transcript,
                audioURL: memo.audioURL,
                mood: memo.mood
            )
        }
        return store
    }
}

// Preview wrapper to handle async preview store creation
struct PreviewStoreContainer: View {
    @State private var store = DailyMemoStore()
    
    var body: some View {
        ContentView()
            .task {
                store = PreviewData.createPreviewStore()
            }
    }
} 