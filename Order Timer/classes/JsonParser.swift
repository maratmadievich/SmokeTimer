//
//  JsonParser.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 05.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Foundation

class JsonParser {
    
    let coreDataParser:CoreDataParser
    
    init() {
        coreDataParser = CoreDataParser()
    }
    
    
    public func parseUser (JSONData: Data) -> User {
        print ("parseUser:")
        let user = User()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print ("auth_response:\(json)")
            if let error = json["error"] as? String {
                user.error = error
            } else {
                if let token = json["api_token"] as? String {
                    user.token = token
                    GlobalConstants.user.token = token
                }
                if let cafeName = json["cafe_name"] as? String {
                    user.cafeName = cafeName
                    GlobalConstants.user.cafeName = cafeName
                }
                if let name = json["name"] as? String {
                    user.name = name
                    GlobalConstants.user.name = name
                }
                if let id = json["id"] as? Int {
                    user.id = id
                    GlobalConstants.user.id = id
                }
                if let role = json["role"] as? Int {
                    user.role = role
                    GlobalConstants.user.role = role
                }
                if let cafe = json["cafe"] as? Int {
                    user.cafe = cafe
                    GlobalConstants.user.cafe = cafe
                } else {
                    user.cafe = 1
                    GlobalConstants.user.cafe = 1
                }
                if let phone = json["phone"] as? String {
                    user.phone = phone
                    GlobalConstants.user.phone = phone
                }
                if let paid = json["paid"] as? Int {
                    user.paid = paid
                    GlobalConstants.user.paid = paid
                }
            }
        }
        catch {
             user.error = "В данный момент на устройстве существуют проблемы с сетью"
        }
        return user
    }
    
    
    public func parseSettings (JSONData: Data, cafe: Int) -> Settings {
        let settings = Settings()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print ("settings_response:\(json)")
            if let error = json["error"] as? String {
                settings.error = error
            } else {
                if let request = json["success"] as? [String: Any] {
                    if let name = request["name"] as? String {
                       settings.name = name
                    }
                    if let timeStartOrder = request["order_timer"] as? Int {
                        settings.timeStartOrder = timeStartOrder
                    }
                    if let timeFiveMinutes = request["minutes_timer"] as? Int {
                        settings.timeFiveMinutes = timeFiveMinutes
                    }
                    if let timeWorkTimer = request["work_timer"] as? Int {
                        settings.timeWorkTimer = timeWorkTimer
                    }
                    if let countIterations = request["timer_count"] as? Int {
                        settings.countIterations = countIterations
                    }
                    if let maxOrder = request["max_order"] as? Int {
                        settings.maxOrder = maxOrder
                    }
                    if let maxDelay = request["max_delay"] as? Int {
                        settings.maxDelay = maxDelay
                    }
                    if let height = request["height"] as? CGFloat {
                        settings.height = height
                    }
                    if let width = request["width"] as? CGFloat {
                        settings.width = width
                    }
                    if let open = request["open"] as? Int {
                        settings.open = open
                    }
                    if let waiter = request["waiter"] as? Int {
                        settings.waiter = waiter
                    }
                    if let workspace = request["workspace_count"] as? Int {
                        settings.workspaceCount = workspace
                    }
                    settings.cafe = cafe
                }
            }
        }
        catch {
            print(error)
        }
        return settings
    }
    
    
    public func parseWaiters (JSONData: Data) -> [Waiter] {
        print ("parseWaiters:")
        var waiters = [Waiter]()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
            } else {
                
                if let waitersJson = json["success"] as? [[String: Any]] {
                    print (waitersJson)
                    for waiterJson in waitersJson {
                        let waiter = Waiter()
                        print ("\n waiter \n")
                        if let id = waiterJson["id"] as? Int {
                            print("id " + String(id))
                            waiter.id = id
                        }
                        if let name = waiterJson["name"] as? String {
                            print("name " + name)
                            waiter.name = name
                        }
                        if let login = waiterJson["login"] as? String {
                            print("login " + login)
                            waiter.login = login
                        }
                        if let phone = waiterJson["phone"] as? String {
                            print("phone " + String(phone))
                            waiter.phone = phone
                        }
                        waiters.append(waiter)
                    }
                }
            }
        } catch {
            print(error)
        }
        return waiters
    }
    
    
    public func parseAdd (JSONData: Data) -> CafeResponse {
        print ("parseAdd:")
        let response = CafeResponse()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
                response.isError = true
                response.text = error
            } else {
                response.isError = false
                if let id = json["success"] as? Int {
                    response.id = id
                }
            }
        } catch {
            print(error)
            response.isError = true
            response.text = "Ошибка при изменении базы данных. Обратитесь к Администратору приложения"
        }
        return response
    }
    
    
    public func parseEditDelete (JSONData: Data) -> CafeResponse {
        print ("parseEditDelete:")
        let response = CafeResponse()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
                response.isError = true
                response.text = error
            } else {
                response.isError = false
                if let text = json["success"] as? String {
                    response.text = text
                }
            }
        } catch {
            print(error)
            response.isError = true
            response.text = "Ошибка при изменении базы данных. Обратитесь к Администратору приложения"
        }
        return response
    }
    
    
    public func parseTables (JSONData: Data, cafe: Int) -> [Table] {
        print ("parseTables:")
        var tables = [Table]()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
            } else {
                
                if let tablesJson = json["success"] as? [[String: Any]] {
                    print (tablesJson)
                    for tableJson in tablesJson {
                        let table = Table()
                        if let id = tableJson["id"] as? Int {
                            print("id " + String(id))
                            table.id = id
                        }
                        if let name = tableJson["name"] as? String {
                            print("name " + name)
                            table.name = name
                        }
                        if let x = tableJson["place_x"] as? CGFloat {
                            print("x " + String(describing: x))
                            table.x = x
                        }
                        if let y = tableJson["place_y"] as? CGFloat {
                            print("y " + String(describing: y))
                            table.y = y
                        }
                        if let size = tableJson["size"] as? CGFloat {
                            print("size " + String(describing: size))
                            table.size = size
                        }
                        if let workcpace = tableJson["workspace"] as? Int {
                            print("workcpace " + String(describing: workcpace))
                            table.workspace = workcpace
                        }
                        table.cafe = cafe
                        tables.append(table)
                    }
                }
            }
        } catch {
            print(error)
        }
        return tables
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
    
    
    public func parseDelay (JSONData: Data) -> [Statistic] {
        print ("parseDelay:")
        var statistic = [Statistic]()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
            } else {
                if let statisticsJson = json["success"] as? [[String: Any]] {
                    print (statisticsJson)
                    for statisticJson in statisticsJson {
                        let stat = Statistic()
                        if let id = statisticJson["id"] as? Int {
                            print("id " + String(id))
                            stat.idWaiter = id
                        }
                        if let name = statisticJson["name"] as? String {
                            print("name " + name)
                            stat.name = name
                        }
                        if let count = statisticJson["count"] as? Int {
                            print("count " + String(count))
                            stat.count = count
                        }
                        statistic.append(stat)
                    }
                }
            }
        } catch {
            print(error)
        }
        return statistic
    }
    
    
    public func parseOrder (JSONData: Data, cafe: Int) -> [Order] {
        print ("parseOrder:")
        var orders = [Order]()
        do {
            let json = try JSONSerialization.jsonObject(with: JSONData, options:.mutableContainers) as![String: Any]
            
            print (json)
            if let error = json["error"] as? String {
                print ("Ошибка: " + error)
            } else {
                if let ordersJson = json["success"] as? [[String: Any]] {
                    print (ordersJson)
                    for orderJson in ordersJson {
                        let order = Order()
                        if let id = orderJson["id"] as? Int {
                            print("id " + String(id))
                            order.id = id
                            order.timeId = id
                        }
                        if let idTable = orderJson["table"] as? Int {
                            print("idTable " + String(idTable))
                            order.idTable = idTable
                        }
                        if let cafeNumber = orderJson["number"] as? Int {
                            print("cafeNumber " + String(cafeNumber))
                            order.cafeNumber = cafeNumber
                        }
                        if let status = orderJson["status"] as? Int {
                            print("status " + String(status))
                            order.status = status
                        }
                        if let delay_flag = orderJson["delay_flag"] as? Int {
                            print("delay_flag " + String(delay_flag))
                            order.delay_flag = delay_flag
                        }
                        if let time = orderJson["date"] as? String {
                            print("date " + String(time))
                            order.time = TimeInterval(time)!
                        }
                        order.cafe = cafe
                        orders.append(order)
                    }
                }
            }
        } catch {
            print(error)
        }
        return orders
    }
    
}
