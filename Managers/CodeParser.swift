
import Foundation
import SwiftUI
import RealityKit

struct CodeParser {
    static func parseColor(from code: String) -> UIColor {
        let pattern = "(?i)color[^\\.]*\\.\\s*([a-zA-Z]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return .cyan }
        
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results.first {
            let colorName = nsString.substring(with: match.range(at: 1)).lowercased()
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
        return parseFloat(from: code, keyword: "size") ?? defaultSize
    }
    
    static func parseWidth(from code: String, defaultWidth: Float = 0.1) -> Float {
        return parseFloat(from: code, keyword: "width") ?? defaultWidth
    }
    
    static func parseHeight(from code: String, defaultHeight: Float = 0.1) -> Float {
        return parseFloat(from: code, keyword: "height") ?? defaultHeight
    }
    
    static func parseDepth(from code: String, defaultDepth: Float = 0.1) -> Float {
        return parseFloat(from: code, keyword: "depth") ?? defaultDepth
    }
    
    static func parseChamfer(from code: String, defaultChamfer: Float = 0.0) -> Float {
        return parseFloat(from: code, keyword: "chamfer") ?? defaultChamfer
    }
    
    // MARK: - Physics Parsers
    
    static func parseMass(from code: String, defaultMass: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "mass") ?? defaultMass
    }
    
    static func parseRestitution(from code: String, defaultRestitution: Float = 0.5) -> Float {
        return parseFloat(from: code, keyword: "restitution") ?? defaultRestitution
    }
    
    static func parseShape(from code: String) -> String {
        let pattern = "(?i)shape[^\\.]*\\.\\s*([a-zA-Z]+)|(?i)shape[^=]*=\\s*\"?([a-zA-Z]+)\"?"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return "box" }
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        if let match = results.first {
            if match.range(at: 1).location != NSNotFound {
                return nsString.substring(with: match.range(at: 1)).lowercased()
            } else if match.range(at: 2).location != NSNotFound {
                return nsString.substring(with: match.range(at: 2)).lowercased()
            }
        }
        return "box"
    }
    
    static func parseForceX(from code: String, defaultValue: Float = 0.0) -> Float {
        return parseFloat(from: code, keyword: "forceX") ?? defaultValue
    }
    
    static func parseForceY(from code: String, defaultValue: Float = 5.0) -> Float {
        return parseFloat(from: code, keyword: "forceY") ?? defaultValue
    }
    
    static func parseForceZ(from code: String, defaultValue: Float = -3.0) -> Float {
        return parseFloat(from: code, keyword: "forceZ") ?? defaultValue
    }
    
    static func parseForce(from code: String) -> SIMD3<Float> {
        let x = parseForceX(from: code)
        let y = parseForceY(from: code)
        let z = parseForceZ(from: code)
        return SIMD3<Float>(x, y, z)
    }
    
    // MARK: - Position Parsers (Level 2)
    
    static func parsePositionX(from code: String, defaultValue: Float = 0.0) -> Float {
        return parseFloat(from: code, keyword: "positionX") ?? defaultValue
    }
    
    // MARK: - Scale Parsers (Level 5)
    
    static func parseScaleX(from code: String, defaultValue: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "scaleX") ?? defaultValue
    }
    
    static func parseScaleY(from code: String, defaultValue: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "scaleY") ?? defaultValue
    }
    
    static func parseScaleZ(from code: String, defaultValue: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "scaleZ") ?? defaultValue
    }
    
    static func parseScale(from code: String) -> SIMD3<Float> {
        let x = parseScaleX(from: code)
        let y = parseScaleY(from: code)
        let z = parseScaleZ(from: code)
        return SIMD3<Float>(x, y, z)
    }
    
    // MARK: - Material Parsers (Level 6)
    
    static func parseMetallic(from code: String, defaultValue: Bool = true) -> Bool {
        let pattern = "metallic:\\s*(true|false)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return defaultValue }
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        if let match = results.first {
            let value = nsString.substring(with: match.range(at: 1))
            return value == "true"
        }
        return defaultValue
    }
    
    // MARK: - Projectile Parsers (Level 8)
    
    static func parseSpeed(from code: String, defaultValue: Float = 8.0) -> Float {
        return parseFloat(from: code, keyword: "speed") ?? defaultValue
    }
    
    static func parseRadius(from code: String, defaultValue: Float = 0.08) -> Float {
        return parseFloat(from: code, keyword: "radius") ?? defaultValue
    }
    
    // MARK: - Stack Parsers (Level 9)
    
    static func parseCount(from code: String, defaultValue: Int = 5) -> Int {
        if let floatVal = parseFloat(from: code, keyword: "count") {
            return max(1, min(Int(floatVal), 15))
        }
        return defaultValue
    }
    // MARK: - Gravity Parser (Level 6)
    
    static func parseGravity(from code: String, defaultGravity: Float = 9.8) -> Float {
        return parseFloat(from: code, keyword: "gravity") ?? defaultGravity
    }
    
    // MARK: - Solar System Parsers (Levels 1-5)
    
    static func parseOrbitRadius(from code: String, defaultValue: Float = 0.5) -> Float {
        return parseFloat(from: code, keyword: "orbitRadius") ?? defaultValue
    }
    
    static func parseOrbitSpeed(from code: String, defaultValue: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "orbitSpeed") ?? defaultValue
    }
    
    static func parseRotationSpeed(from code: String, defaultValue: Float = 1.0) -> Float {
        return parseFloat(from: code, keyword: "rotationSpeed") ?? defaultValue
    }
    
    // MARK: - Core Parser Helpers
    
    // Core function to find a float value assigned to a specific keyword
    static func parseFloat(from code: String, keyword: String) -> Float? {
        // Matches the keyword, followed by any non-digit/non-minus characters, then a float
        let pattern = "(?i)\(keyword)[^0-9-]*(-?[0-9]*\\.?[0-9]+)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let nsString = code as NSString
        let results = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        if let match = results.first, let value = Float(nsString.substring(with: match.range(at: 1))) {
            return value
        }
        return nil
    }
}
