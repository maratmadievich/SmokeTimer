//
//  BorderView.swift
//  Сafe Timer
//
//  Created by Марат Нургалиев on 09.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class BorderView: UIView {

//    @IBInspectable var borderWidth: CGFloat = 0.0 {
//        didSet {
//            self.layer.borderWidth = borderWidth
//        }
//    }
//    
//
//    @IBInspectable var borderColor: UIColor = UIColor.clear {
//        didSet {
//            self.layer.borderColor = borderColor.cgColor
//        }
//    }
    
//    self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
    
    
    func addTopBorderWithColor(color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5)
        self.layer.addSublayer(border)
    }
    
    
    func addBottomBorderWithColor(color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5)
        self.layer.addSublayer(border)
    }
    
    
//    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
//        let border = CALayer()
//        border.backgroundColor = color.cgColor
//        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
//        self.layer.addSublayer(border)
//    }
//    
//    
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
