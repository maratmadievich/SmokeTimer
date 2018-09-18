//
//  AlertExit.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 09.05.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class AlertExit: UIView {
    
    var delegate: AlertExitProtocol?
    @IBOutlet weak var constraintPad: NSLayoutConstraint!
    @IBOutlet weak var constraintPhone: NSLayoutConstraint!
    var forPhone = false
    
    
    override func layoutSubviews() {
        if (forPhone) {
            self.removeConstraint(self.constraintPad)
        } else {
            self.removeConstraint(self.constraintPhone)
        }
    }
    
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        delegate?.responseExit(response: 0)
        self.removeFromSuperview()
    }
    
    
    @IBAction func btnExitClicked(_ sender: Any) {
        delegate?.responseExit(response: 1)
        self.removeFromSuperview()
    }

    
    
}

