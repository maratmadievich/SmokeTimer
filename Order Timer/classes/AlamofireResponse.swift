//
//  AlamofireResponse.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 23.09.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


protocol BackEndLoginProtocol {
    
    func returnLoginSuccess()
    func returnError(error: String)
}

protocol BackEndSettingsProtocol {
    
    func returnSettingsSuccess()
    func returnUpdateSuccess()
    func returnError(error: String)
}

protocol BackEndWaitersProtocol {
    
    func returnMy(waiters: [Waiter])
    func returnAddSuccess()
    func returnUpdateSuccess()
    func returnChangeSuccess()
    func returnDeleteSuccess()
    func returnError(error: String)
}

protocol BackEndTablesProtocol {
    
    func returnMy(tables: [Table])
    func returnAdd(table: Table)
    func returnDelete(table: Int)
    func returnError(error: String)
}

protocol BackEndOrdersProtocol {
    
    func returnMy(orders: [Order])
    func returnAdd(order: Order)
    func returnUpdate(order: Order)
    func returnDelete(order: Order)
    func returnError(error: String)
}

protocol BackEndDelaysProtocol {
    
    func returnMy(delays: [Statistic])
    func returnAdd(delay: Delay)
    func returnError(error: String)
}

protocol BackEndChangeOpenProtocol {
    
    func returnSuccess(isOpen: Bool)
    func returnError(error: String)
}



class AlamofireResponse {
    
    init() {}
// Запросы из ViewController
    
    
    private func checkIsPaument(statusCode: Int) {
        if (statusCode == 403 && !GlobalConstants.isHookNotPaid) {
            GlobalConstants.isHookNotPaid = true
            if let url = URL(string: GlobalConstants.mainAPI + "payment") {
                UIApplication.shared.open(url, options: [:])
            }
             _ = GlobalConstants.currentViewController.navigationController?.popToRootViewController(animated: true)//popViewController(animated: true)
            return
        }
    }
    
    func getToken(parameters: Parameters, delegate: BackEndLoginProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/getToken",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                var canWork = true
                if let statusCode = response.response?.statusCode {
                    canWork = statusCode == 403 ? false:true
                    self.checkIsPaument(statusCode: statusCode)
                }
                if canWork {
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        print("getToken_data: \(json)")
                        if let error = json["error"].string {
                            delegate.returnError(error: error)
                        } else {
                            GlobalConstants.jsonParser.parseUser(json: json)
                            delegate.returnLoginSuccess()
                        }
                        break
                    case .failure(let error):
                        delegate.returnError(error: error.localizedDescription)
                        break
                    }
                } else {
                    GlobalConstants.isHookNotPaid = false
                    delegate.returnError(error: "")
                }
        }
    }
    
    
    func getTables(delegate: BackEndTablesProtocol) {
        var parameters = Parameters()
        parameters["api_token"] = GlobalConstants.user.token
        parameters["cafe"] = GlobalConstants.user.cafe
        
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeTable",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeTable_data: \(json)")
                    
                    if let error = json["error"].string {
                        delegate.returnError(error: error)
                    } else {
                        var tables = [Table]()
                        if let data = json["success"].array {
                            tables = GlobalConstants.jsonParser.parseTables(data: data)
                        }
                        delegate.returnMy(tables: tables)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func add(table: Table, parameters: Parameters, delegate: BackEndTablesProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/AddTable",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("AddTable_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseAdd(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        table.id = response.id
                        delegate.returnAdd(table: table)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func delete(table: Int, parameters: Parameters, delegate: BackEndTablesProtocol)  {
        Alamofire.request(GlobalConstants.mainAPI + "api/DeleteTable",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("DeleteTable_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnDelete(table: table)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func getOrders(delegate: BackEndOrdersProtocol) {
        var parameters = Parameters()
        parameters["api_token"] = GlobalConstants.user.token
        parameters["cafe"] = GlobalConstants.user.cafe
        
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeOrder",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeOrder_data: \(json)")
                    
                    if let error = json["error"].string {
                        delegate.returnError(error: error)
                    } else {
                        var orders = [Order]()
                        if let data = json["success"].array {
                            orders = GlobalConstants.jsonParser.parseOrders(data: data)
                        }
                        delegate.returnMy(orders: orders)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func add(order: Order, parameters: Parameters, delegate: BackEndOrdersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/AddOrder",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("AddOrder_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseAdd(json: json)
                    if response.isError {
//                        delegate.returnError(error: response.text)
                    } else {
                        order.id = response.id
                        order.needUpdate = 0
                        delegate.returnAdd(order: order)
                    }
                    break
                
                case .failure(_):
//                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
        
    
    func update(order: Order, parameters: Parameters, delegate: BackEndOrdersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/UpdateOrder",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("UpdateOrder_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if !response.isError {
                        order.needUpdate = 0
                        delegate.returnUpdate(order: order)
                    }
                    break
                    
                case .failure(_):
                    break
                }
        }
    }
    
    
    func delete(order: Order, parameters: Parameters, delegate: BackEndOrdersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/DeleteOrder",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("DeleteOrder_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if !response.isError {
                        delegate.returnDelete(order: order)
                    }
                    break
                    
                case .failure(_):
                    break
                }
        }
    }
    
    
    func getDelays(parameters: Parameters, delegate: BackEndDelaysProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeDelay",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeDelay_data: \(json)")
                    if let error = json["error"].string {
                        delegate.returnError(error: error)
                    } else {
                        var delays = [Statistic]()
                        if let data = json["success"].array {
                            delays = GlobalConstants.jsonParser.parseDelays(data: data)
                        }
                        delegate.returnMy(delays: delays)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func add(delay: Delay, parameters: Parameters, delegate: BackEndDelaysProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/AddDelay",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("AddDelay_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseAdd(json: json)
                    if !response.isError {
                        delegate.returnAdd(delay: delay)
                    }
                    break
                    
                case .failure(_):
                    break
                }
        }
    }
    
    
    
    
    
    
    
    func changeOpen(isOpen: Bool, delegate: BackEndChangeOpenProtocol) {
        var parameters = Parameters()
        parameters["api_token"] = GlobalConstants.user.token
        parameters["cafe"] = GlobalConstants.user.cafe
        parameters["waiter"] = GlobalConstants.user.id
        parameters["open"] = isOpen ? "0":"1"
        
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeChangeOpen",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeChangeOpen_data: \(json)")
                    
                    if let error = json["error"].string {
                        delegate.returnError(error: error)
                    } else {
                        GlobalConstants.settings.waiter = GlobalConstants.user.id
                        delegate.returnSuccess(isOpen: isOpen)
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    
// Запросы из View
    func getSettings(delegate: BackEndSettingsProtocol) {
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
                    if let statusCode = response.response?.statusCode {
//                        self.checkIsPaument(statusCode: 403)
                        self.checkIsPaument(statusCode: statusCode)
                    }
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        print("CafeDetailed_data: \(json)")
                        
                        if let error = json["error"].string {
                            GlobalConstants.settings.error = error
                            delegate.returnError(error: error)
                        } else if let data = json["success"].dictionary {
                            GlobalConstants.jsonParser.parseSettings(data: data)
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
    
    
    func saveSettings(parameters: Parameters, delegate: BackEndSettingsProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeUpdate",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeUpdate_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnUpdateSuccess()
//                        delegate.returnError(error: "Сохранение прошло успешно")
                    }
                    break
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    break
                }
        }
    }
    
    
    func getWaiters(delegate: BackEndWaitersProtocol) {
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
                    if let statusCode = response.response?.statusCode {
                        self.checkIsPaument(statusCode: statusCode)
                    }
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        print("CafeWaiter_data: \(json)")
                        
                        if let error = json["error"].string {
                            delegate.returnError(error: error)
                        } else if let data = json["success"].array {
                            let waiters = GlobalConstants.jsonParser.parseWaiters(data: data)
                            delegate.returnMy(waiters: waiters)
                        }
                        break
                        
                    case .failure(let error):
                        delegate.returnError(error: error.localizedDescription)
                        break
                    }
            }
        }
    }
    
    
    func addWaiter(parameters: Parameters, delegate: BackEndWaitersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/AddWaiter",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("AddWaiter_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseAdd(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnAddSuccess()
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func updateWaiter(parameters: Parameters, delegate: BackEndWaitersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/UpdateWaiter",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("UpdateWaiter_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnUpdateSuccess()
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    func changeWaiter(parameters: Parameters, delegate: BackEndWaitersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/CafeChangeWaiter",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("CafeChangeWaiter_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnChangeSuccess()
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
    func deleteWaiter(parameters: Parameters, delegate: BackEndWaitersProtocol) {
        Alamofire.request(GlobalConstants.mainAPI + "api/DeleteWaiter",
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default)
            .responseJSON {
                response in
                if let statusCode = response.response?.statusCode {
                    self.checkIsPaument(statusCode: statusCode)
                }
                
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    print("DeleteWaiter_data: \(json)")
                    let response = GlobalConstants.jsonParser.parseEditDelete(json: json)
                    if response.isError {
                        delegate.returnError(error: response.text)
                    } else {
                        delegate.returnDeleteSuccess()
                    }
                    break
                    
                case .failure(let error):
                    delegate.returnError(error: error.localizedDescription)
                    break
                }
        }
    }
    
    
}
