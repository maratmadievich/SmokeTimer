//
//  Order.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 12.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import Foundation

class Order {
    
    var id: Int
    var idTable: Int
    var cafeNumber: Int
    var status: Int
    var delay_flag: Int
    var time: TimeInterval
    var timeId: Int
    var cafe: Int
    var needUpdate: Int
    var tableName: String
    
    init() {
        id = -1
        idTable = -1
        cafeNumber = -1
        status = -1
        time = -1
        delay_flag = -1
        timeId = -1
        cafe = -1
        needUpdate = -1
        tableName = ""
    }
}
