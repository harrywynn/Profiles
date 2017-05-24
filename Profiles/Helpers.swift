//
//  Helpers.swift
//  Passport-Challenge
//
//  Created by Harry J Wynn IV on 5/24/17.
//  Copyright © 2017 Harry J Wynn IV. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    public static func capitalizeFirstLetter(_ input: String) -> String {
        let first = String(input.characters.prefix(1)).capitalized
        let other = String(input.characters.dropFirst())
        return first + other
    }
    
}

extension UIImageView {
    
    func setRounded() {
        let radius = (self.frame.width / 2)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}

extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
    
}
