import SwiftUI

enum AppTheme {
    @MainActor static var background: Color {
        ThemeManager.shared.isDarkMode ? .black : .white
    }
    
    @MainActor static var textColor: Color {
        ThemeManager.shared.isDarkMode ? .white : .black
    }
    
    @MainActor static var secondaryText: Color {
        ThemeManager.shared.isDarkMode ? .gray : .secondary
    }
    
    static let primaryRed = Color(red: 1, green: 0, blue: 0)
    static let darkRed = Color(red: 0.8, green: 0, blue: 0)
    static let buttonHighlight = Color(red: 0.6, green: 0, blue: 0)
    
    static let titleFont = Font.custom("Helvetica Neue", size: 24).weight(.bold)
    static let bodyFont = Font.custom("Helvetica Neue", size: 16)
    static let captionFont = Font.custom("Helvetica Neue", size: 12)
    
    static let tabBarBackground = Color.black
    
    @MainActor static func applyTheme() {
        let isDark = ThemeManager.shared.isDarkMode
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().barTintColor = isDark ? .black : .white
        UINavigationBar.appearance().tintColor = UIColor(AppTheme.primaryRed)
    }
} 
