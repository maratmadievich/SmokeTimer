//
//  ViewExtension.swift
//  Order Timer
//
//  Created by Admin on 21.09.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON



protocol AlamofireViewProtocol {
    
    func returnError(error: String)
    func returnSettingsSuccess()
    func returnMy(waiters: [Waiter])
}

extension UIView {
    
    func getSettings(delegate: AlamofireViewProtocol) {
        if (!Connectivity.isConnectedToInternet) {
            delegate.returnError(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            
            Alamofire.request(GlobalConstants.mainAPI + "api/CafeDetailed",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default)
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        print("CafeDetailed_data: \(json)")
                        
                        if let error = json["error"].string {
                            GlobalConstants.settings.error = error
                            delegate.returnError(error: error)
                        } else {
                            if let data = json["success"].dictionary {
                                if let name = data["name"]?.string {
                                    GlobalConstants.settings.name = name
                                }
                                if let timeStartOrder = data["order_timer"]?.int {
                                    GlobalConstants.settings.timeStartOrder = timeStartOrder
                                }
                                if let timeFiveMinutes = data["minutes_timer"]?.int {
                                    GlobalConstants.settings.timeFiveMinutes = timeFiveMinutes
                                }
                                if let timeWorkTimer = data["work_timer"]?.int {
                                    GlobalConstants.settings.timeWorkTimer = timeWorkTimer
                                }
                                if let countIterations = data["timer_count"]?.int {
                                    GlobalConstants.settings.countIterations = countIterations
                                }
                                if let maxOrder = data["max_order"]?.int {
                                    GlobalConstants.settings.maxOrder = maxOrder
                                }
                                if let maxDelay = data["max_delay"]?.int {
                                    GlobalConstants.settings.maxDelay = maxDelay
                                }
                                if let height = data["height"]?.float {
                                    GlobalConstants.settings.height = CGFloat(height)
                                }
                                if let width = data["width"]?.float {
                                    GlobalConstants.settings.width = CGFloat(width)
                                }
                                if let open = data["open"]?.int {
                                    GlobalConstants.settings.open = open
                                }
                                if let waiter = data["waiter"]?.int {
                                    GlobalConstants.settings.waiter = waiter
                                }
                                if let workspace = data["workspace_count"]?.int {
                                    GlobalConstants.settings.workspaceCount = workspace
                                }
                                GlobalConstants.settings.cafe = GlobalConstants.user.cafe
                            }
                        }
                        delegate.returnSettingsSuccess()
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
            }
        }
    }
    
    
    func saveSettings(parameters: Parameters, delegate: AlamofireViewProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeUpdate",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeUpdate_data: \(json)")
                    
                    if let error = json["error"].string {
                        delegate.returnError(error: error)
                    } else if json["success"].string != nil {
                        delegate.returnError(error: "Сохранение прошло успешно")
                    }
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
        }
    }
    
    
    func getWaiters(delegate: AlamofireViewProtocol) {
        
        if (!Connectivity.isConnectedToInternet) {
            delegate.returnError(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            
            Alamofire.request(GlobalConstants.mainAPI + "api/CafeWaiter",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default)
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        print("CafeWaiter_data: \(json)")
                        
                        if let waitersJson = json["success"].array {
                            var waiters = [Waiter]()
                            for waiterJson in waitersJson {
                                let waiter = Waiter()
                                if let id = waiterJson["id"].int {
                                    print("id " + String(id))
                                    waiter.id = id
                                }
                                if let name = waiterJson["name"].string {
                                    print("name " + name)
                                    waiter.name = name
                                }
                                if let login = waiterJson["login"].string {
                                    print("login " + login)
                                    waiter.login = login
                                }
                                if let phone = waiterJson["phone"].string {
                                    print("phone " + String(phone))
                                    waiter.phone = phone
                                }
                                waiters.append(waiter)
                            }
                            delegate.returnMy(waiters: waiters)
                        } else if let error = json["error"].string {
                            delegate.returnError(error: error)
                        }
                        break
                        
                    case .failure(let error):
                        delegate.returnError(error: error.localizedDescription)
                        break
                    }
            }
        }
    }

    
}
