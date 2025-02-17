import SwiftUI

struct MemosListView: View {
    @ObservedObject var memoStore: VoiceMemoStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(memoStore.memos) { memo in
                    NavigationLink(destination: MemoDetailView(memo: memo, memoStore: memoStore)) {
                        VStack(alignment: .leading) {
                            Text(memo.title)
                                .font(.headline)
                            Text(memo.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        memoStore.deleteMemo(memoStore.memos[index])
                    }
                }
            }
            .navigationTitle("MEMOS")
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .foregroundColor(AppTheme.textColor)
        }
    }
}

#Preview {
    MemosListView(memoStore: VoiceMemoStore())
        .task {
            // Preview will show empty store
        }
} 
