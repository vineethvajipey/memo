import SwiftUI

struct ContentView: View {
    @StateObject private var memoStore = VoiceMemoStore()
    
    var body: some View {
        TabView {
            RecordingTab(memoStore: memoStore)
                .tabItem {
                    Label("Record", systemImage: "record.circle")
                }
            
            MemosListView(memoStore: memoStore)
                .tabItem {
                    Label("Memos", systemImage: "list.bullet")
                }
        }
    }
}

#Preview {
    PreviewStoreContainer()
} 
