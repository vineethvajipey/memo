import SwiftUI

struct CalendarView: View {
    @ObservedObject var memoStore: DailyMemoStore
    @Binding var selectedDate: Date?
    @State private var displayedMonth = Date()
    @State private var showingDayMemos = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Calendar Grid
            CalendarGridView(
                displayedMonth: $displayedMonth,
                selectedDate: $selectedDate,
                memoStore: memoStore
            )
            .padding()
            
            // Day Memos Slide-up Section
            if let selectedDate = selectedDate {
                VStack {
                    // Header with date
                    HStack {
                        Text(selectedDate.formatted(date: .long, time: .omitted))
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.textColor)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring()) {
                                self.selectedDate = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppTheme.secondaryText)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Memos list
                    let dayMemos = memosForDate(selectedDate)
                    if dayMemos.isEmpty {
                        Text("No memos for this day")
                            .font(AppTheme.bodyFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(dayMemos) { memo in
                                    NavigationLink(destination: MemoDetailView(memo: memo, memoStore: memoStore)) {
                                        DailyMemoRow(memo: memo)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(AppTheme.background)
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Calendar")
        .animation(.spring(), value: selectedDate)
    }
    
    private func memosForDate(_ date: Date) -> [DailyMemo] {
        memoStore.memos.filter { memo in
            Calendar.current.isDate(memo.createdAt, inSameDayAs: date)
        }
    }
}

struct CalendarGridView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date?
    let memoStore: DailyMemoStore
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month and year header
            HStack {
                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(AppTheme.titleFont)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button {
                        displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    
                    Button {
                        displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .padding(.bottom)
            
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(AppTheme.bodyFont)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(AppTheme.secondaryText)
                }
            }
            
            // Calendar grid
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 7), spacing: 12) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: selectedDate.map { calendar.isDate(date, inSameDayAs: $0) },
                            hasMemos: !memosForDate(date).isEmpty
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                if selectedDate.map({ calendar.isDate(date, inSameDayAs: $0) }) ?? false {
                                    // Deselect if tapping the same date
                                    selectedDate = nil
                                } else {
                                    selectedDate = date
                                }
                            }
                        }
                    } else {
                        Color.clear
                            .gridCellUnsizedAxes([.horizontal, .vertical])
                    }
                }
            }
        }
    }
    
    private func memosForDate(_ date: Date) -> [DailyMemo] {
        memoStore.memos.filter { memo in
            calendar.isDate(memo.createdAt, inSameDayAs: date)
        }
    }
    
    private func daysInMonth() -> [Date?] {
        var days: [Date?] = []
        
        let interval = calendar.dateInterval(of: .month, for: displayedMonth)!
        let firstDayOfMonth = interval.start
        
        // Add empty cells for days before the first of the month
        let weekdayOfFirst = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 1..<weekdayOfFirst {
            days.append(nil)
        }
        
        // Add all days of the month
        var currentDate = firstDayOfMonth
        while currentDate < interval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Add empty cells to complete the last week if needed
        let remainingDays = (7 - (days.count % 7)) % 7
        for _ in 0..<remainingDays {
            days.append(nil)
        }
        
        return days
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool?
    let hasMemos: Bool
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 20, weight: .medium))
            
            if hasMemos {
                Circle()
                    .fill(AppTheme.primaryRed)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(isSelected == true ? AppTheme.primaryRed.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected == true ? AppTheme.primaryRed : Color.clear, lineWidth: 1)
        )
    }
}

struct DailyMemoRow: View {
    let memo: DailyMemo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(memo.title)
                    .font(AppTheme.bodyFont)
                    .foregroundColor(AppTheme.textColor)
                
                Spacer()
                
                Image(systemName: memo.mood.icon)
                    .foregroundColor(memo.mood.color)
            }
            
            Text(memo.createdAt.formatted(date: .omitted, time: .shortened))
                .font(AppTheme.captionFont)
                .foregroundColor(AppTheme.secondaryText)
        }
        .padding()
        .background(AppTheme.background.opacity(0.5))
        .cornerRadius(10)
    }
} 