//
//  NewTableView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 03.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class NewTableView: UIView {


    @IBOutlet weak var table: CornerView!
    @IBOutlet weak var order: UIView!
    
    @IBOutlet weak var labelTableName: UILabel!
    @IBOutlet weak var labelOrderCount: UILabel!
    @IBOutlet weak var labelTimer: UILabel!
    
    @IBOutlet weak var orderWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timerHeightConstraint: NSLayoutConstraint!
    
    
    
    var shapeLayer = CAShapeLayer()
    
    var time = -1.0
    var difference = 0
    var timer = Timer()
    
    var viewWidth:CGFloat = -1
    var viewHeight:CGFloat = -1
    var isTableLong = false
    
   
    override func layoutSubviews() {
        if (viewWidth > viewHeight) {
            table.cornerRadius = (viewHeight - 30) / 2
            if (isTableLong) {
                timerWidthConstraint.constant = viewHeight - 30
                timerHeightConstraint.constant = viewHeight - 30
            }
        } else {
            table.cornerRadius = (viewWidth - 30) / 2
            if (isTableLong) {
                timerWidthConstraint.constant = viewWidth - 30
                timerHeightConstraint.constant = viewWidth - 30
            }
        }
        
    }
    
    
    func checkTimer() {
        difference = Int(time - Date().timeIntervalSince1970) + 1
        if (difference > 0) {
            checkDelays()
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(NewTableView.checkDelays)), userInfo: nil, repeats: true)
        } else {
            labelTimer.text = ""
        }
    }
    
    
    func countTime() {
        var minutes = String(Int(difference / 60))
        var seconds = String(difference % 60)
        if minutes.count == 1 {
            minutes = "0" + minutes
        }
        if seconds.count == 1 {
            seconds = "0" + seconds
        }
        labelTimer.text = minutes + ":" + seconds
    }
    
    
    @objc func checkDelays() {
        difference -= 1
        if (difference > 0) {
            countTime()
        } else {
            labelTimer.text = ""
            timer.invalidate()
        }
    }
    
    

}
