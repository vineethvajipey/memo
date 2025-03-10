import SwiftUI

struct ContentView: View {
    @StateObject private var memoStore = DailyMemoStore()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingSettings = false
    @State private var selectedTab = 1
    @State private var selectedDate: Date?
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                AddMemoView(memoStore: memoStore, selectedTab: $selectedTab, date: Date())
                    .tabItem {
                        Label("New", systemImage: "plus.circle.fill")
                    }
                    .tag(0)
                
                CalendarView(memoStore: memoStore, selectedDate: $selectedDate)
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
                    .tag(1)
                
                MemosListView(memoStore: memoStore, selectedDate: $selectedDate)
                    .tabItem {
                        Label("Memos", systemImage: "list.bullet")
                    }
                    .tag(2)
            }
            .tint(AppTheme.primaryRed)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(AppTheme.primaryRed)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    PreviewStoreContainer()
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section("Appearance") {
                    Toggle(isOn: $themeManager.isDarkMode) {
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(themeManager.isDarkMode ? .white : .yellow)
                            Text("Dark Mode")
                                .foregroundColor(AppTheme.textColor)
                        }
                    }
                    .tint(AppTheme.primaryRed)
                }
                
                Section("About") {
                    Text("Version 1.0")
                        .foregroundColor(AppTheme.textColor)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppTheme.background)
            .scrollContentBackground(.hidden)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppTheme.primaryRed)
                }
            }
        }
    }
} 
