import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case light
    case dark
    case arcade
    
    var id: String { self.rawValue }
    
    var background: Color {
        switch self {
        case .light: return Color.white
        case .dark: return Color.black
        case .arcade: return Color(red: 0.1, green: 0.0, blue: 0.2)
        }
    }
    
    var text: Color {
        switch self {
        case .light: return Color.black
        case .dark: return Color.white
        case .arcade: return Color.cyan
        }
    }
    
    var accent: Color {
        switch self {
        case .light: return Color.blue
        case .dark: return Color.white
        case .arcade: return Color.pink
        }
    }
    
    var secondaryBackground: Color {
        switch self {
        case .light: return Color.gray.opacity(0.1)
        case .dark: return Color.gray.opacity(0.2)
        case .arcade: return Color.purple.opacity(0.3)
        }
    }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("selectedTheme") var currentTheme: AppTheme = .dark
    
    var background: Color { currentTheme.background }
    var text: Color { currentTheme.text }
    var accent: Color { currentTheme.accent }
    var secondaryBackground: Color { currentTheme.secondaryBackground }
}
