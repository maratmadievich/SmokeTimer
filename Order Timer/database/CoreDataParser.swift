//
//  CoreDataParser.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 08.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import CoreData
import Foundation


class CoreDataParser {
    
    var appDelegate:AppDelegate
    var managedContext:NSManagedObjectContext
    
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
    }
    
    
//    func getTableName(id: Int) -> String {
//        
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreTable")
//        let pr1 = NSPredicate(format: "id == %@", String(id))
//        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
//        fetchRequest.predicate = compound
//        var coreTables = [CoreTable]()
//        
//        do {
//            coreTables = try managedContext.fetch(fetchRequest) as! [CoreTable]
//            for coreTable in coreTables {
//                return coreTable.name!
//            }
//        } catch {
//            print ("What's going wrong! \(error)")
//        }
//        return ""
//    }
    
    func saveTables(tables: [Table]) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreTable",in: managedContext)
        for table in tables {
            let NStable = NSManagedObject(entity: entity!, insertInto:managedContext)
            NStable.setValue(table.name, forKey: "name")
            NStable.setValue(table.id, forKey: "id")
            NStable.setValue(table.x, forKey: "x")
            NStable.setValue(table.y, forKey: "y")
            NStable.setValue(table.cafe, forKey: "cafe")
            
            do {
                try NStable.managedObjectContext?.save()
            } catch {
                print ("saveTable - Ошибка: \(error)")
            }
        }
    }
    
    func getTables(cafe: Int) -> [Table] {
        var tables = [Table]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreTable")
        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound

        var coreTables = [CoreTable]()
        
        do {
            coreTables = try managedContext.fetch(fetchRequest) as! [CoreTable]
            for coreTable in coreTables {
                let table = Table()
                table.name = coreTable.name!
                table.id = Int(coreTable.id)
                table.x = CGFloat(coreTable.x)
                table.y = CGFloat(coreTable.y)
                table.cafe = Int(coreTable.cafe)
                tables.append(table)
            }
        } catch {
            print ("getTables - Ошибка: \(error)")
        }
        return tables
    }

    func updateTable(table: Table) -> Bool {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreTable")
        let pr1 = NSPredicate(format: "id == %@", String(table.id))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        
        do {
            let coreTables = try managedContext.fetch(fetchRequest)
            let coreTable = coreTables[0] as! NSManagedObject
            coreTable.setValue(table.name, forKey: "name")
            coreTable.setValue(table.x, forKey: "x")
            coreTable.setValue(table.y, forKey: "y")
            coreTable.setValue(table.cafe, forKey: "cafe")
            do {
                try managedContext.save()
            } catch {
                print ("updateTable - Ошибка: \(error)")
                return false
            }
        } catch {
            print ("updateTable - Ошибка: \(error)")
            return false
        }
        return true
    }
 
    func deleteTables(cafe: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreTable")
        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreTables = [Any]()
        
        do {
            coreTables = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteTables - Ошибка: \(error)")
        }
        
        if coreTables.count > 0 {
            for coreTable in coreTables {
                managedContext.delete(coreTable as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteTables - Ошибка: \(error)")
            }
        }
    }
    
    
    func saveSettings(settings: Settings) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreSettings",in: managedContext)
        let NSSettings = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        NSSettings.setValue(settings.open, forKey: "open")
        NSSettings.setValue(settings.width, forKey: "width")
        NSSettings.setValue(settings.height, forKey: "height")
        NSSettings.setValue(settings.waiter, forKey: "waiter")
        NSSettings.setValue(settings.maxDelay, forKey: "maxDelay")
        NSSettings.setValue(settings.maxOrder, forKey: "maxOrder")
        NSSettings.setValue(settings.timeWorkTimer, forKey: "timeWorkTimer")
        NSSettings.setValue(settings.timeStartOrder, forKey: "timeStartOrder")
        NSSettings.setValue(settings.timeFiveMinutes, forKey: "timeFiveMinutes")
        NSSettings.setValue(settings.countIterations, forKey: "countIterations")
        NSSettings.setValue(settings.cafe, forKey: "cafe")
        
        do {
            try NSSettings.managedObjectContext?.save()
        } catch {
            print ("saveSettings - Ошибка: \(error)")
        }
    }
    
    func getSettings(cafe: Int) -> Settings {
        let settings = Settings()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreSettings")
        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreSettings = [CoreSettings]()
        
        do {
            coreSettings = try managedContext.fetch(fetchRequest) as! [CoreSettings]
            if coreSettings.count > 0 {
                for coreSetting in coreSettings {
                    settings.open = Int(coreSetting.open)
                    settings.width = CGFloat(coreSetting.width)
                    settings.height = CGFloat(coreSetting.height)
                    settings.waiter = Int(coreSetting.waiter)
                    settings.maxDelay = Int(coreSetting.maxDelay)
                    settings.maxOrder = Int(coreSetting.maxOrder)
                    settings.timeWorkTimer = Int(coreSetting.timeWorkTimer)
                    settings.timeStartOrder = Int(coreSetting.timeStartOrder)
                    settings.timeFiveMinutes = Int(coreSetting.timeFiveMinutes)
                    settings.countIterations = Int(coreSetting.countIterations)
                    settings.cafe = Int(coreSetting.cafe)
                }
            }
        } catch {
            print ("getSettings - Ошибка: \(error)")
        }
        return settings
    }
    
    func deleteSettings() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreSettings")
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [])
        fetchRequest.predicate = compound
        var coreSettings = [Any]()
        
        do {
            coreSettings = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteSettings - Ошибка: \(error)")
        }
        
        if coreSettings.count > 0 {
            for coreSetting in coreSettings {
                managedContext.delete(coreSetting as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteSettings - Ошибка: \(error)")
            }
        }
    }
    
    
    func saveUser(user: User) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreUser",in: managedContext)
        let NSUser = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        NSUser.setValue(user.id, forKey: "id")
        NSUser.setValue(user.role, forKey: "role")
        NSUser.setValue(user.name, forKey: "name")
        NSUser.setValue(user.phone, forKey: "phone")
        NSUser.setValue(user.token, forKey: "token")
        NSUser.setValue(user.cafe, forKey: "cafe")
        NSUser.setValue(user.login, forKey: "login")
        NSUser.setValue(user.pass, forKey: "pass")
        
        do {
            try NSUser.managedObjectContext?.save()
        } catch {
             print ("saveUser - Ошибка: \(error)")
        }
    }

    func getUser(login: String, pass: String) -> User? {
        let user = User()
        user.error = "Пользователь не найден"
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreUser")
        let pr1 = NSPredicate(format: "pass == %@", String(pass))
        let pr2 = NSPredicate(format: "login == %@", String(login))
        let pr3 = NSPredicate(format: "role == %@", String(0))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1, pr2, pr3])
        
        fetchRequest.predicate = compound
        var coreUsers = [CoreUser]()
        
        do {
            coreUsers = try managedContext.fetch(fetchRequest) as! [CoreUser]
            for coreUser in coreUsers {
                user.id = Int(coreUser.id)
                user.role = Int(coreUser.role)
                user.name = coreUser.name!
                user.phone = coreUser.phone!
                user.token = coreUser.token!
                user.cafe = Int(coreUser.cafe)
                user.login = coreUser.login!
                user.pass = coreUser.pass!
            }
        } catch {
            print ("saveUser - Ошибка: \(error)")
            user.error = "Ошибка при получении данных о пользователе"
        }
        return user
    }
    
    
    func getUserLogin() -> String {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreUser")
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [])
        
        fetchRequest.predicate = compound
        var coreUsers = [CoreUser]()
        
        do {
            coreUsers = try managedContext.fetch(fetchRequest) as! [CoreUser]
            for coreUser in coreUsers {
                return coreUser.login!
            }
        } catch {
            return ""
        }
        return ""
    }
    

    func deleteUser(id: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreUser")
        let pr1 = NSPredicate(format: "id == %@", String(id))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreUsers = [Any]()
        do {
            coreUsers = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteUser - Ошибка: \(error)")
        }
        
        if coreUsers.count > 0 {
            for coreUser in coreUsers {
                managedContext.delete(coreUser as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteUser - Ошибка: \(error)")
            }
        }
    }
    
    
    func deleteUsers() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreUser")
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [])
        fetchRequest.predicate = compound
        var coreUsers = [Any]()
        do {
            coreUsers = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteUser - Ошибка: \(error)")
        }
        
        if coreUsers.count > 0 {
            for coreUser in coreUsers {
                managedContext.delete(coreUser as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteUser - Ошибка: \(error)")
            }
        }
    }
    
    
    func saveOrder(order: Order) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreOrder",in: managedContext)
        let NSOrder = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        NSOrder.setValue(order.id, forKey: "id")
        NSOrder.setValue(order.cafe, forKey: "cafe")
        NSOrder.setValue(order.idTable, forKey: "idTable")
        NSOrder.setValue(order.cafeNumber, forKey: "number")
        NSOrder.setValue(order.status, forKey: "status")
        NSOrder.setValue(order.timeId, forKey: "timeId")
        NSOrder.setValue(order.delay_flag, forKey: "delay_flag")
        NSOrder.setValue(order.time, forKey: "date")
        NSOrder.setValue(order.needUpdate, forKey: "needUpdate")
        
        do {
            try NSOrder.managedObjectContext?.save()
        } catch {
            print ("saveOrder - Ошибка: \(error)")
        }
    }
    
    func updateOrder(order: Order) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "timeId == %@", String(order.timeId))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        
        do {
            let coreOrders = try managedContext.fetch(fetchRequest)
            if coreOrders.count == 0 {
                saveOrder(order: order)
            } else {
                let NSOrder = coreOrders[0] as! NSManagedObject
                NSOrder.setValue(order.id, forKey: "id")
                NSOrder.setValue(order.cafe, forKey: "cafe")
                NSOrder.setValue(order.idTable, forKey: "idTable")
                NSOrder.setValue(order.cafeNumber, forKey: "number")
                NSOrder.setValue(order.status, forKey: "status")
                NSOrder.setValue(order.timeId, forKey: "timeId")
                NSOrder.setValue(order.delay_flag, forKey: "delay_flag")
                NSOrder.setValue(order.time, forKey: "date")
                NSOrder.setValue(order.needUpdate, forKey: "needUpdate")
                do {
                    try managedContext.save()
                } catch {
                    print ("updateOrder - Ошибка: \(error)")
                }
            }
        } catch {
            print ("updateOrder - Ошибка: \(error)")
        }
    }
    
    func updateDeleteOrders(tableRow: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "idTable == %@", String(tableRow))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        
        do {
            let coreOrders = try managedContext.fetch(fetchRequest)// as! [CoreOrder]
            if coreOrders.count == 0 {
            } else {
                for order in coreOrders {
                    let NSOrder = order as! NSManagedObject
                    NSOrder.setValue(2, forKey: "needUpdate")
                    do {
                        try managedContext.save()
                    } catch {
                        print ("updateOrder - Ошибка: \(error)")
                    }
                }
            }
        } catch {
            print ("updateOrder - Ошибка: \(error)")
        }
    }
    
    func getOrders(cafe: Int) -> [Order] {
        var orders = [Order]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        
        fetchRequest.predicate = compound
        var coreOrders = [CoreOrder]()
        
        do {
            coreOrders = try managedContext.fetch(fetchRequest) as! [CoreOrder]
            for coreOrder in coreOrders {
                let order = Order()
                order.id = Int(coreOrder.id)
                order.status = Int(coreOrder.status)
                order.cafeNumber = Int(coreOrder.number)
                order.idTable = Int(coreOrder.idTable)
                order.cafe = Int(coreOrder.cafe)
                order.time = Double(coreOrder.date)
                order.delay_flag = Int(coreOrder.delay_flag)
                order.timeId = Int(coreOrder.timeId)
                order.needUpdate = Int(coreOrder.needUpdate)
                orders.append(order)
            }
        } catch {
           print ("getOrder - Ошибка: \(error)")
        }
        return orders
    }
    
    func getMaxOrderNumber(idTable: Int) -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "idTable == %@", String(idTable))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        
        fetchRequest.predicate = compound
        var coreOrders = [CoreOrder]()
        
        do {
            coreOrders = try managedContext.fetch(fetchRequest) as! [CoreOrder]
            var cafeNumber = 0
            for coreOrder in coreOrders {
                if (cafeNumber < Int(coreOrder.number)) {
                    cafeNumber = Int(coreOrder.number)
                }
            }
            return cafeNumber
        } catch {
            print ("getOrdersCount - Ошибка: \(error)")
            return 0
        }
    }
    
    func deleteOrder(cafe: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreOrders = [Any]()
        do {
            coreOrders = try managedContext.fetch(fetchRequest)
        } catch {
           print ("deleteOrder - Ошибка: \(error)")
        }
        
        if coreOrders.count > 0 {
            for coreOrder in coreOrders {
                managedContext.delete(coreOrder as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteOrder - Ошибка: \(error)")
            }
        }
    }
    
    
    func deleteOrderByTimeId(order: Order) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "timeId == %@", String(order.timeId))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreOrders = [Any]()
        do {
            coreOrders = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteOrderByTimeId - Ошибка: \(error)")
        }
        
        if coreOrders.count > 0 {
            for coreOrder in coreOrders {
                managedContext.delete(coreOrder as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteOrderByTimeId - Ошибка: \(error)")
            }
        }
    }
    
    
    func deleteOrderByDate(date: Double) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreOrder")
        let pr1 = NSPredicate(format: "date == %@", String(date))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreOrders = [Any]()
        do {
            coreOrders = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteOrderByDate - Ошибка: \(error)")
        }
        
        if coreOrders.count > 0 {
            for coreOrder in coreOrders {
                managedContext.delete(coreOrder as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteOrderByDate - Ошибка: \(error)")
            }
        }
    }
    
    
    func getRequests() -> [Request] {
        var requests = [Request]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreRequest")
//        let pr1 = NSPredicate(format: "cafe == %@", String(cafe))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [])//pr1
        fetchRequest.predicate = compound
        var coreRequests = [CoreRequest]()
        
        do {
            coreRequests = try managedContext.fetch(fetchRequest) as! [CoreRequest]
            for coreRequest in coreRequests {
                let request = Request()
                request.id = Int(coreRequest.id)
                request.url = coreRequest.url!
                request.type = Int(coreRequest.type)
                request.parameters = getParameters(idRequest: request.id)
                requests.append(request)
            }
        } catch {
            print ("getRequests - Ошибка: \(error)")
        }
        return requests
    }
    
    func deleteRequest(id: Int) {
        deleteParameters(idRequest: id)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreRequest")
        let pr1 = NSPredicate(format: "id == %@", String(id))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreRequests = [Any]()
        do {
            coreRequests = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteRequest - Ошибка: \(error)")
        }
        
        if coreRequests.count > 0 {
            for coreRequest in coreRequests {
                managedContext.delete(coreRequest as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteRequest - Ошибка: \(error)")
            }
        }
    }
    
    
    func saveRequest(request: Request) {
        saveParameters(request: request)
        let entity =  NSEntityDescription.entity(forEntityName: "CoreRequest",in: managedContext)
        let NSRequest = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        NSRequest.setValue(request.id, forKey: "id")
        NSRequest.setValue(request.type, forKey: "type")
        NSRequest.setValue(request.url, forKey: "url")
        
        do {
            try NSRequest.managedObjectContext?.save()
        } catch {
            print ("saveRequest - Ошибка: \(error)")
        }
    }
    
    
    func getParameters(idRequest: Int) -> [String:String] {
        var parameters = [String:String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreParameter")
        let pr1 = NSPredicate(format: "idRequest == %@", String(idRequest))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])//
        fetchRequest.predicate = compound
        var coreParameters = [CoreParameter]()
        
        do {
            coreParameters = try managedContext.fetch(fetchRequest) as! [CoreParameter]
            for coreParameter in coreParameters {
                parameters[coreParameter.key!] = coreParameter.value!
            }
        } catch {
            print ("getParameters - Ошибка: \(error)")
        }
        return parameters
    }
    
    
    func saveParameters(request: Request) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreParameter",in: managedContext)
        for parameter in request.parameters {
            let NSParameter = NSManagedObject(entity: entity!, insertInto:managedContext)
            NSParameter.setValue(request.id, forKey: "idRequest")
            NSParameter.setValue(parameter.key, forKey: "key")
            NSParameter.setValue(parameter.value, forKey: "value")
            
            do {
                try NSParameter.managedObjectContext?.save()
            } catch {
                print ("saveParameters - Ошибка: \(error)")
            }
        }
    }
    
    
    func deleteParameters(idRequest: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreParameter")
        let pr1 = NSPredicate(format: "idRequest == %@", String(idRequest))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreParameters = [Any]()
        do {
            coreParameters = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteParameters - Ошибка: \(error)")
        }
        
        if coreParameters.count > 0 {
            for coreParameter in coreParameters {
                managedContext.delete(coreParameter as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteParameters - Ошибка: \(error)")
            }
        }
    }
    
    
    func getDelays() -> [Delay] {
        var delays = [Delay]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreDelay")
//        let pr1 = NSPredicate(format: "idRequest == %@", String(idRequest))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [])//pr1
        fetchRequest.predicate = compound
        var coreDelays = [CoreDelay]()
        
        do {
            coreDelays = try managedContext.fetch(fetchRequest) as! [CoreDelay]
            for coreDelay in coreDelays {
                let delay = Delay()
                delay.date = coreDelay.date
                delay.cafe = Int(coreDelay.cafe)
                delay.waiter = Int(coreDelay.waiter)
                delay.id = Int(coreDelay.id)
                delays.append(delay)
            }
        } catch {
            print ("getDelays - Ошибка: \(error)")
        }
        return delays
    }
    
    
    func saveDelay(delay: Delay) {
        let entity =  NSEntityDescription.entity(forEntityName: "CoreDelay",in: managedContext)
        let NSDelay = NSManagedObject(entity: entity!, insertInto:managedContext)
        NSDelay.setValue(delay.date, forKey: "date")
        NSDelay.setValue(delay.cafe, forKey: "cafe")
        NSDelay.setValue(delay.waiter, forKey: "waiter")
        NSDelay.setValue(delay.id, forKey: "id")
        do {
            try NSDelay.managedObjectContext?.save()
        } catch {
            print ("saveParameters - Ошибка: \(error)")
        }
    }
    
    
    func deleteDelay(delay: Delay) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"CoreDelay")
        let pr1 = NSPredicate(format: "id == %@", String(delay.id))
        let compound = NSCompoundPredicate.init(andPredicateWithSubpredicates: [pr1])
        fetchRequest.predicate = compound
        var coreDelays = [Any]()
        do {
            coreDelays = try managedContext.fetch(fetchRequest)
        } catch {
            print ("deleteDelay - Ошибка: \(error)")
        }
        
        if coreDelays.count > 0 {
            for coreDelay in coreDelays {
                managedContext.delete(coreDelay as! NSManagedObject)
            }
            do {
                try managedContext.save()
            } catch {
                print ("deleteDelay - Ошибка: \(error)")
            }
        }
    }
    
    
}
