//
//  SettingsLeftView.swift
//  Сafe Timer
//
//  Created by Марат Нургалиев on 14.02.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class SettingsLeftView: UIView {
    
    
//    func addTopBorderWithColor(color: UIColor) {
//        let border = CALayer()
//        border.backgroundColor = color.cgColor
//        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5)
//        self.layer.addSublayer(border)
//    }
//
//
//    func addBottomBorderWithColor(color: UIColor) {
//        let border = CALayer()
//        border.backgroundColor = color.cgColor
//        border.frame = CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5)
//        self.layer.addSublayer(border)
//    }
    
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    
//    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
//        let border = CALayer()
//        border.backgroundColor = color.cgColor
//        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
//        self.layer.addSublayer(border)
//    }
    
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
}
