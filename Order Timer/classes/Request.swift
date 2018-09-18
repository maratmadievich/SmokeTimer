//
//  request.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 23.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import Foundation

class Request {
    var id: Int
    var url: String
    var parameters: [String: String]
    var type: Int//0 - add; 1 - edit; 2 - delete; 3 - close
    
    init() {
        url = ""
        parameters = [String: String]()
        type = -1
        id = -1
    }
}
