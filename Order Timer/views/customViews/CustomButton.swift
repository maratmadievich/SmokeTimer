//
//  CustomButton.swift
//  Сafe Timer
//
//  Created by Марат Нургалиев on 13.02.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}
