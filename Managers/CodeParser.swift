
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
    
    static func parseForce(from code: String) -> SIMD3<Float> {
        // Look for SIMD3<Float>(x, y, z) pattern, simplified
        // Or just look for specific values if the lesson allows editing specific vector components
        // For Lesson 4, we might just look for a multiplier or specific Z value
        
        let pattern = "SIMD3<Float>\\(0,\\s*0,\\s*(-?[0-9]*\\.?[0-9]+)\\)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return SIMD3<Float>(0, 0, -10) }
        
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first, let zForce = Float(nsString.substring(with: match.range(at: 1))) {
             return SIMD3<Float>(0, 0, zForce)
        }
        
        return SIMD3<Float>(0, 0, -10)
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
