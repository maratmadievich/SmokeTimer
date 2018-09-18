//
//  CoreDelay+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreDelay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreDelay> {
        return NSFetchRequest<CoreDelay>(entityName: "CoreDelay")
    }

    @NSManaged public var cafe: Int16
    @NSManaged public var date: Double
    @NSManaged public var id: Int16
    @NSManaged public var waiter: Int16

}
