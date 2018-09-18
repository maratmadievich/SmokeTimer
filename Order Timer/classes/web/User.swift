//
//  User.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 05.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import Foundation

class User {
    
    var id: Int
    var token: String
    var role: Int
    var cafe: Int
    var name: String
    var cafeName: String
    var error: String
    var phone: String
    var login: String
    var pass: String
    var paid: Int
    
    init() {
        id = -1
        cafe = 0
        role = 0
        name = ""
        token = ""
        error = ""
        phone = ""
        login = ""
        pass = ""
        cafeName = ""
        paid = 0
    }
}
