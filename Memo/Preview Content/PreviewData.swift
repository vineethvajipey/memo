import Foundation
import SwiftUI

struct PreviewData {
    static let sampleMemos = [
        VoiceMemo(
            title: "Meeting Notes",
            transcript: "Discuss project timeline and deliverables for Q2",
            audioURL: URL(string: "file://sample.m4a")!,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        VoiceMemo(
            title: "Shopping List",
            transcript: "Milk, eggs, bread, and vegetables for dinner",
            audioURL: URL(string: "file://sample2.m4a")!,
            createdAt: Date().addingTimeInterval(-7200)
        )
    ]
    
    @MainActor
    static func createPreviewStore() -> VoiceMemoStore {
        let store = VoiceMemoStore()
        for memo in sampleMemos {
            store.addMemo(title: memo.title, transcript: memo.transcript, audioURL: memo.audioURL)
        }
        return store
    }
}

// Preview wrapper to handle async preview store creation
struct PreviewStoreContainer: View {
    @State private var store = VoiceMemoStore()
    
    var body: some View {
        ContentView()
            .task {
                store = PreviewData.createPreviewStore()
            }
    }
} 