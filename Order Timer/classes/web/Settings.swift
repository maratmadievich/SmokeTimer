//
//  Settings.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 08.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class Settings {
    
    var timeStartOrder:Int
    var timeFiveMinutes:Int
    var timeWorkTimer:Int
    var countIterations:Int
    var maxOrder:Int
    var maxDelay:Int
    var width: CGFloat
    var height: CGFloat
    var name: String
    var error: String
    var open: Int
    var waiter: Int
    var cafe: Int
    var workspaceCount: Int
    
    init() {
        timeStartOrder = -1
        timeFiveMinutes = -1
        timeWorkTimer = -1
        countIterations = -1
        maxOrder = -1
        maxDelay = -1
        width = -1
        height = -1
        name = ""
        error = ""
        open = -1
        waiter = -1
        cafe = -1
        workspaceCount = 1
    }
}
