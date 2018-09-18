//
//  ShadowView.swift
//  Сafe Timer
//
//  Created by Марат Нургалиев on 13.02.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    override func layoutSubviews() {
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = true ? UIScreen.main.scale : 1
    }

  
    
}

