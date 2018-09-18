//
//  Response.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 06.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import Foundation

class CafeResponse {
    
    var id:Int
    var isError: Bool
    var text: String
    
    init() {
        id = -1
        isError = false
        text = ""
    }
}
