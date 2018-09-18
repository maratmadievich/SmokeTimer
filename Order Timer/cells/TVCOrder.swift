//
//  TVCOrder.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 15.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class TVCOrder: UITableViewCell {
    
    var delegateUpdateOrder: UpdateOrderProtocol?
    
    @IBOutlet weak var viewMain: CornerView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    var orderNumber = -1
    var orderRow = -1
    
    var time = -1.0
    var timer = Timer()
    
    var status = -1
    var difference = 0
    var tableName = ""

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        difference = Int(time - Date().timeIntervalSince1970)
        if (difference > 0) {
            countTime()
            viewMain.backgroundColor = Table().getColor(status: 1)
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(TVCOrder.checkDelays)), userInfo: nil, repeats: true)
        } else {
            viewMain.backgroundColor = Table().getColor(status: -1)
            labelTime.text = "Таймер просрочен"
        }
        setOrderName()
        setStatus()
    }
    
    
    @IBAction func btnUpdateOrderClicked(_ sender: Any) {
        delegateUpdateOrder?.updateOrder(orderRow: orderRow)
    }
    
    
    
    @objc func checkDelays() {
        difference -= 1
        if (difference > 0) {
            countTime()
        } else {
            viewMain.backgroundColor = Table().getColor(status: -1)
            labelTime.text = "Таймер просрочен"
            timer.invalidate()
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
        labelTime.text = minutes + ":" + seconds
    }
    
    
    func setOrderName() {
        if orderNumber > 0 {
            if tableName.count > 0 {
                labelName.text = "Столик " + tableName + " Заказ № " + String(orderNumber)
            } else {
                labelName.text = "Заказ № " + String(orderNumber)
            }
        }
    }
    
    
    func setStatus() {
        var text = ""
        switch status {
        case -1:
            break
            
        case 0:
            break
            
        case 1:
            text = "Статус \"Принят заказ\""
            break
            
        case 2:
            text = "Статус \"Таймер 5 минут\""
            break

        default:
            text = "Статус \"Рабочий таймер\""
            break
        }
        labelStatus.text = text
    }
    
    

}
