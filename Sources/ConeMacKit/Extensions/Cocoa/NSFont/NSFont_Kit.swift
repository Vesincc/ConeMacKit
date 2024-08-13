//
//  NSFont_Kit.swift
//  ConeMacKit
//
//  Created by HanQi on 2024/4/9.
//

import Foundation
import AppKit

public extension NSFont {
    
    enum HelveticaNeueWeight: String {
        case regular = "HelveticaNeue"
        case italic = "HelveticaNeue-Italic"
        case light = "HelveticaNeue-Light"
        case lightItalic = "HelveticaNeue-LightItalic"
        case thin = "HelveticaNeue-Thin"
        case thinItalic = "HelveticaNeue-ThinItalic"
        case bold = "HelveticaNeue-Bold"
        case boldItalic = "HelveticaNeue-BoldItalic"
        case medium = "HelveticaNeue-Medium"
        case mediumItalic = "HelveticaNeue-MediumItalic"
    }
    
    
    convenience init(helveticaNeue size: CGFloat, weight: HelveticaNeueWeight) {
        self.init(name: weight.rawValue, size: size)!
    }
    
}
