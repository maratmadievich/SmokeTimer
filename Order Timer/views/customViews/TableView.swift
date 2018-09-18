//
//  TableView.swift
//  Сafe Timer
//
//  Created by Марат Нургалиев on 14.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class TableView: UIView {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCount: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
    @IBOutlet weak var imageWarning: UIImageView!
    
    
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
