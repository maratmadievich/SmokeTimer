//
//  ButtonCornerView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 09.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class ButtonCornerView: UIButton {
    

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    
}
