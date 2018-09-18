//
//  CoreOrder+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreOrder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreOrder> {
        return NSFetchRequest<CoreOrder>(entityName: "CoreOrder")
    }

    @NSManaged public var timeId: Int16
    @NSManaged public var status: Int16
    @NSManaged public var number: Int16
    @NSManaged public var needUpdate: Int16
    @NSManaged public var idTable: Int16
    @NSManaged public var id: Int16
    @NSManaged public var delay_flag: Int16
    @NSManaged public var date: Double
    @NSManaged public var cafe: Int16

}
