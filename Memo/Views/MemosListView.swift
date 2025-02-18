import SwiftUI

struct MemosListView: View {
    @ObservedObject var memoStore: DailyMemoStore
    @Binding var selectedDate: Date?
    @State private var searchText = ""
    @State private var showingAddMemo = false
    @State private var selectedMoodFilter: DailyMemo.Mood?
    @State private var selectedTab = 1
    
    private var filteredMemos: [DailyMemo] {
        var memos = memoStore.memos
        
        // Apply date filter if selected
        if let date = selectedDate {
            memos = memos.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
        }
        
        // Apply mood filter if selected
        if let mood = selectedMoodFilter {
            memos = memos.filter { $0.mood == mood }
        }
        
        // Apply search text
        if !searchText.isEmpty {
            memos = memos.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.transcript.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return memos
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppTheme.secondaryText)
                    TextField("Search memos", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Mood filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(DailyMemo.Mood.allCases, id: \.self) { mood in
                            Button(action: {
                                selectedMoodFilter = selectedMoodFilter == mood ? nil : mood
                            }) {
                                HStack {
                                    Image(systemName: mood.icon)
                                    Text(mood.rawValue)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedMoodFilter == mood ? mood.color.opacity(0.2) : Color.gray.opacity(0.1))
                                )
                                .foregroundColor(selectedMoodFilter == mood ? mood.color : AppTheme.secondaryText)
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Date filter indicator
            if let date = selectedDate {
                HStack {
                    Text("Showing memos for \(date.formatted(date: .long, time: .omitted))")
                        .font(AppTheme.captionFont)
                        .foregroundColor(AppTheme.secondaryText)
                    
                    Button(action: {
                        withAnimation {
                            selectedDate = nil
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.secondaryText)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Memos list
            if filteredMemos.isEmpty {
                VStack(spacing: 20) {
                    Text(searchText.isEmpty ? "No memos found" : "No matches found")
                        .foregroundColor(AppTheme.secondaryText)
                    
                    Button(action: {
                        showingAddMemo = true
                    }) {
                        Label("Add Memo", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredMemos) { memo in
                        NavigationLink(destination: MemoDetailView(memo: memo, memoStore: memoStore)) {
                            DailyMemoRow(memo: memo)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            memoStore.deleteMemo(filteredMemos[index])
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Memos")
        .sheet(isPresented: $showingAddMemo) {
            AddMemoView(memoStore: memoStore, 
                       selectedTab: $selectedTab,
                       date: selectedDate ?? Date())
        }
    }
}

#Preview {
    MemosListView(memoStore: DailyMemoStore(), selectedDate: .constant(nil))
} 
