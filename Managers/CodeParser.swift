
import Foundation
import SwiftUI
import RealityKit

struct CodeParser {
    static func parseColor(from code: String) -> UIColor {
        let pattern = "color:\\s*\\.([a-zA-Z]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return .cyan }
        
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            let colorName = nsString.substring(with: match.range(at: 1))
            switch colorName {
            case "red": return .red
            case "blue": return .blue
            case "green": return .green
            case "yellow": return .yellow
            case "orange": return .orange
            case "purple": return .purple
            case "cyan": return .cyan
            case "magenta": return .magenta
            case "white": return .white
            case "black": return .black
            default: return .cyan
            }
        }
        return .cyan
    }
    
    static func parseSize(from code: String, defaultSize: Float = 0.1) -> Float {
        let pattern = "size:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultSize
    }
    
    static func parseWidth(from code: String, defaultWidth: Float = 0.1) -> Float {
        let pattern = "width:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultWidth
    }
    
    static func parseHeight(from code: String, defaultHeight: Float = 0.1) -> Float {
        let pattern = "height:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultHeight
    }
    
    static func parseDepth(from code: String, defaultDepth: Float = 0.1) -> Float {
        let pattern = "depth:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultDepth
    }
    
    static func parseChamfer(from code: String, defaultChamfer: Float = 0.0) -> Float {
        let pattern = "chamfer:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultChamfer
    }
    
    // MARK: - Physics Parsers
    
    static func parseMass(from code: String, defaultMass: Float = 1.0) -> Float {
        let pattern = "mass:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultMass
    }
    
    static func parseRestitution(from code: String, defaultRestitution: Float = 0.5) -> Float {
        let pattern = "restitution:\\s*([0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultRestitution
    }
    
    static func parseShape(from code: String) -> String {
        let pattern = "shape:\\s*([a-zA-Z]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return "box" }
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        if let match = results.first {
            return nsString.substring(with: match.range(at: 1)).lowercased()
        }
        return "box"
    }
    
    static func parseForceX(from code: String, defaultValue: Float = 0.0) -> Float {
        let pattern = "forceX:\\s*(-?[0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultValue
    }
    
    static func parseForceY(from code: String, defaultValue: Float = 5.0) -> Float {
        let pattern = "forceY:\\s*(-?[0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultValue
    }
    
    static func parseForceZ(from code: String, defaultValue: Float = -3.0) -> Float {
        let pattern = "forceZ:\\s*(-?[0-9]*\\.?[0-9]+)"
        return parseFloat(from: code, pattern: pattern) ?? defaultValue
    }
    
    static func parseForce(from code: String) -> SIMD3<Float> {
        let x = parseForceX(from: code)
        let y = parseForceY(from: code)
        let z = parseForceZ(from: code)
        return SIMD3<Float>(x, y, z)
    }
    
    // Helper
    private static func parseFloat(from code: String, pattern: String) -> Float? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        if let match = results.first, let value = Float(nsString.substring(with: match.range(at: 1))) {
            return value
        }
        return nil
    }
}
