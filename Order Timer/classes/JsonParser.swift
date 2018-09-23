//
//  JsonParser.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 05.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class JsonParser {
    
    let coreDataParser:CoreDataParser
    
    init() {
        coreDataParser = CoreDataParser()
    }
    
    
    public func parseUser (json: JSON) {
        print ("parseUser:")
        if let token = json["api_token"].string {
            GlobalConstants.user.token = token
        }
        if let cafeName = json["cafe_name"].string {
            GlobalConstants.user.cafeName = cafeName
        }
        if let name = json["name"].string {
            GlobalConstants.user.name = name
        }
        if let id = json["id"].int {
            GlobalConstants.user.id = id
        }
        if let role = json["role"].int {
            GlobalConstants.user.role = role
        }
        if let cafe = json["cafe"].int {
            GlobalConstants.user.cafe = cafe
        } else {
            GlobalConstants.user.cafe = 1
        }
        if let phone = json["phone"].string {
            GlobalConstants.user.phone = phone
        }
        if let paid = json["paid"].int {
            GlobalConstants.user.paid = paid
        }
    }
    
    
    public func parseSettings (data: [String: JSON]) {
        print("ParseSettings:")
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
    
    
    public func parseWaiters (data: [JSON]) -> [Waiter] {
        print ("parseWaiters:")
        var waiters = [Waiter]()
        for waiterJson in data {
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
        return waiters
    }
    
    
    public func parseAdd (json: JSON) -> CafeResponse {
        print ("parseAdd:")
        let response = CafeResponse()
        if let error = json["error"].string {
            print ("Ошибка: " + error)
            response.isError = true
            response.text = error
        } else {
            response.isError = false
            if let id = json["success"].int {
                response.id = id
            }
        }
        return response
    }
    
    
    public func parseEditDelete (json: JSON) -> CafeResponse {
        print ("parseEditDelete:")
        let response = CafeResponse()
        if let error = json["error"].string {
            print ("Ошибка: " + error)
            response.isError = true
            response.text = error
        } else {
            response.isError = false
            if let text = json["success"].string {
                response.text = text
            }
        }
        return response
    }
    
    
    public func parseTables (data: [JSON]) -> [Table] {
        print ("parseTables:")
        var tables = [Table]()
        for tableJson in data {
            let table = Table()
            if let id = tableJson["id"].int {
                print("id " + String(id))
                table.id = id
            }
            if let name = tableJson["name"].string{
                print("name " + name)
                table.name = name
            }
            if let x = tableJson["place_x"].double {
                print("x " + String(describing: x))
                table.x = CGFloat(x)
            }
            if let y = tableJson["place_y"].double {
                print("y " + String(describing: y))
                table.y = CGFloat(y)
            }
            if let size = tableJson["size"].double {
                print("size " + String(describing: size))
                table.size = CGFloat(size)
            }
            if let workcpace = tableJson["workspace"].int {
                print("workcpace " + String(describing: workcpace))
                table.workspace = workcpace
            }
            table.cafe = GlobalConstants.user.cafe
            tables.append(table)
        }
        return tables
    }
    
    
    public func parseOrders (data: [JSON]) -> [Order] {
        var orders = [Order]()
        for orderJson in data {
            let order = Order()
            if let id = orderJson["id"].int {
                print("id " + String(id))
                order.id = id
                order.timeId = id
            }
            if let idTable = orderJson["table"].int {
                print("idTable " + String(idTable))
                order.idTable = idTable
            }
            if let cafeNumber = orderJson["number"].int {
                print("cafeNumber " + String(cafeNumber))
                order.cafeNumber = cafeNumber
            }
            if let status = orderJson["status"].int {
                print("status " + String(status))
                order.status = status
            }
            if let delay_flag = orderJson["delay_flag"].int {
                print("delay_flag " + String(delay_flag))
                order.delay_flag = delay_flag
            }
            if let time = orderJson["date"].string {
                print("date " + String(time))
                order.time = TimeInterval(time)!
            }
            order.cafe = GlobalConstants.user.cafe
            orders.append(order)
        }
        return orders
    }
    
    
    public func parseSms (JSONData: Data) -> CafeResponse {
        print ("parseSms:")
        let response = CafeResponse()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let status = json["status"] as? String {
                print ("Статус: " + status)
                if (status == "OK") {
                    response.isError = false
                    response.text = "Смс доставлено"
                } else {
                    response.isError = true
                    response.text = "Ошибка при отправке смс"
                }
            }
        } catch {
            print(error)
            response.isError = true
            response.text = "Ошибка при изменении базы данных. Обратитесь к Администратору приложения"
        }
        return response
    }
    
    
    public func parseDelays (data: [JSON]) -> [Statistic] {
        print ("parseDelay:")
        var statistics = [Statistic]()
        for statisticJson in data {
            let stat = Statistic()
            if let id = statisticJson["id"].int {
                print("id " + String(id))
                stat.idWaiter = id
            }
            if let name = statisticJson["name"].string {
                print("name " + name)
                stat.name = name
            }
            if let count = statisticJson["count"].int {
                print("count " + String(count))
                stat.count = count
            }
            statistics.append(stat)
        }
        return statistics
    }
    
    
    
    
}
