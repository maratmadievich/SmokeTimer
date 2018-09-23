//
//  AlertFive.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 06.05.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class AlertFive: UIView {
    
    var delegate: AlertFiveOrderProtocol?
    
    @IBOutlet weak var labelInfo: UILabel!
    
    @IBOutlet weak var btnOne: ButtonCornerView!
    @IBOutlet weak var btnTwo: ButtonCornerView!
    @IBOutlet weak var btnThree: ButtonCornerView!
    
    var tableRow = -1
    var orderRow = -1
    
    var typeWork = -1
    
    
    override func layoutSubviews() {
//        labelInfo.text = "В данный момент вы принесли заказ клиенту. Клиент:"
    }
    
    
    @IBAction func btnNextClicked(_ sender: Any) {
        if typeWork == 1 {
            delegate?.responseAlertChangeTable(response: 0, tableRow: tableRow)
        } else {
            delegate?.responseAlertFive(response: 0, tableRow: tableRow, orderRow: orderRow)
        }
        self.removeFromSuperview()
    }
    
    
    @IBAction func btnRestartClicked(_ sender: Any) {
        if typeWork == 1 {
            delegate?.responseAlertChangeTable(response: 1, tableRow: tableRow)
        } else {
             delegate?.responseAlertFive(response: 1, tableRow: tableRow, orderRow: orderRow)
        }
        self.removeFromSuperview()
    }
    
    
    @IBAction func btnEndClicked(_ sender: Any) {
        if typeWork == 1 {
            delegate?.responseAlertChangeTable(response: 2, tableRow: tableRow)
        } else {
            delegate?.responseAlertFive(response: 2, tableRow: tableRow, orderRow: orderRow)
        }
        self.removeFromSuperview()
    }
    
    
}
