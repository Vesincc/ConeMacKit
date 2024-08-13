//
//  File.swift
//  
//
//  Created by HanQi on 2023/11/16.
//

import Foundation
import AppKit


public extension NSColor {
    
    
    /// 初始化颜色
    /// - Parameter hex: rgba
    convenience init(rgba hex: UInt64) {
        self.init(red:  CGFloat((hex & 0xff000000) >> 24) / 255,
                  green: CGFloat((hex & 0x00ff0000) >> 16) / 255,
                  blue: CGFloat((hex & 0x0000ff00) >> 8) / 255,
                  alpha: CGFloat((hex & 0x000000ff) >> 0) / 255)
    }
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hex: rgb
    ///   - alpha: alpha
    convenience init(rgb hex: UInt32, alpha: CGFloat = 1) {
        self.init(red:  CGFloat((hex & 0xff0000) >> 16) / 255,
                  green: CGFloat((hex & 0x00ff00) >> 8) / 255,
                  blue: CGFloat((hex & 0x0000ff) >> 0) / 255,
                  alpha: alpha)
    }
    
    /// 初始化颜色
    /// - Parameter hex: rgba || rgb
    convenience init(rgba hexString: String) {
        var string = hexString.replacingOccurrences(of: "0x", with: "").replacingOccurrences(of: "#", with: "")
        if string.count <= 4 {
            var str = ""
            for character in string {
                str.append(String(repeating: String(character), count: 2))
            }
            string = str
        }
        let scanner = Scanner(string: string)
        var hexValue: UInt64 = 0
        if scanner.scanHexInt64(&hexValue) {
            self.init(rgba: hexValue)
        } else {
            self.init(rgba: 0xFFFFFF)
        }
    }
    
    /// 初始化颜色
    /// - Parameters:
    ///   - hex: rgb
    ///   - alpha: alpha
    convenience init(rgb hexString: String, alpha: CGFloat = 1) {
        var string = ""
        let lowercaseHexString = hexString.lowercased()
        if lowercaseHexString.hasPrefix("0x") {
            string = lowercaseHexString.replacingOccurrences(of: "0x", with: "")
        } else if hexString.hasPrefix("#") {
            string = hexString.replacingOccurrences(of: "#", with: "")
        } else {
            string = hexString
        }

        if string.count == 3 {
            var str = ""
            string.forEach { str.append(String(repeating: String($0), count: 2)) }
            string = str
        }

        guard let hexValue = UInt32(string, radix: 16) else {
            self.init(rgb: 0xFFFFFF)
            return
        }
        var trans = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }
        self.init(rgb: hexValue, alpha: trans)
    }
    
    /// 初始化颜色
    /// - Parameter hex: argb
    convenience init(argb hex: UInt32) {
        self.init(red:  CGFloat((hex & 0x00ff0000) >> 16) / 255,
                  green: CGFloat((hex & 0x0000ff00) >> 8) / 255,
                  blue: CGFloat((hex & 0x000000ff) >> 0) / 255,
                  alpha: CGFloat((hex & 0xff000000) >> 24) / 255)
    }
    

    /// 初始化颜色
    /// - Parameter hex: argb || rgb
    convenience init(argb hexString: String) {
        let temp = hexString.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        var hexValue: UInt32 = 0
        let scanner = Scanner(string: temp)
        if scanner.scanHexInt32(&hexValue) {
            self.init(argb: hexValue)
        } else {
            self.init(argb: 0xFFFFFF)
        }
    }
    
}


public extension NSColor {
    
    var redValue: CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    var greenValue: CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    var blueValue: CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
    var alphaValue: CGFloat {
        return cgColor.alpha
    }
    
    /// 过渡颜色 颜色A变化到颜色B
    /// - Parameters:
    ///   - fromColor: 起始
    ///   - toColor: 目标
    ///   - progress: 0.0 - 1.0
    /// - Returns: 过渡色
    class func fromColor(fromColor: NSColor, toColor: NSColor, progress: CGFloat) -> NSColor {
        let pgs = min(progress, 1)
        let fromRed = fromColor.redValue
        let fromGreen = fromColor.greenValue
        let fromBlue = fromColor.blueValue
        let fromAlpha = fromColor.alphaValue
        
        let toRed = toColor.redValue
        let toGreen = toColor.greenValue
        let toBlue = toColor.blueValue
        let toAlpha = toColor.alphaValue
        
        let finalRed = fromRed + (toRed - fromRed) * pgs
        let finalGreen = fromGreen + (toGreen - fromGreen) * pgs
        let finalBlue = fromBlue + (toBlue - fromBlue) * pgs
        let finalAlpha = fromAlpha + (toAlpha - fromAlpha) * pgs
        return NSColor(red: finalRed, green: finalGreen, blue: finalBlue, alpha: finalAlpha)
    }

    
}
