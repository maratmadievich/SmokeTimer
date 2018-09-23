//
//  Extension.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 01.07.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit


struct GlobalConstants {
    
    static let jsonParser = JsonParser()
    static let alamofireResponse = AlamofireResponse()
    static let mainAPI  = "http://server.smoketimer.ru/"
    
    static var user = User()
    static var settings = Settings()
    static var tables = [Table]()
    
    static var isHookNotPaid = false
    static var currentViewController =  UIViewController()
}

struct defaultsKeys {
    static let authToken     = "UniParkAuthToken"
    static let userId        = "UniParkuserID"
    static let appType       = "UniParkAppType"
    static let GoogleMapsKey = "AIzaSyB-Q4drkXQlrZPeUCLlIcXnOBk14pBolM4"
}
