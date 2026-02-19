import SwiftUI

// Simplified to just respect System Mode or manual override
enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selectedTheme") var currentTheme: AppTheme = .dark
    
    // Helper to force the color scheme in ContentView
    var colorScheme: ColorScheme? {
        // Force Dark Mode for Nebula Theme
        return .dark
    }
}
