//
//  Table.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 08.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class Table {
    
    var id: Int
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var name: String
    var cafe: Int
    var workspace: Int
    
    var orders: [Order]
    
    init() {
        name = ""
        id = -1
        x = 0
        y = 0
        size = 0
        cafe = -1
        workspace = 1
        orders = [Order]()
    }
    
    func getColor(status: Int) -> UIColor {
        switch status {
        case -1:
            return UIColor(red: 255/255, green: 4/255, blue: 0/255, alpha: 1)
        case 0:
            return UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
//        case 1:
//            return UIColor(red: 102/255, green: 204/255, blue: 255/255, alpha: 1)
            
//        case 2:
//            return UIColor(red: 255/255, green: 255/255, blue: 153/255, alpha: 1)
        default:
//            return UIColor(red: 255/255, green: 153/255, blue: 0/255, alpha: 1)
            return UIColor(red: 149/255, green: 193/255, blue: 30/255, alpha: 1)
        }
    }
}
