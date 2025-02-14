import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = true
    
    static let shared = ThemeManager()
    
    private init() {}
} 