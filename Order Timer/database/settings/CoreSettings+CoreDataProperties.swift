//
//  CoreSettings+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreSettings> {
        return NSFetchRequest<CoreSettings>(entityName: "CoreSettings")
    }

    @NSManaged public var width: Int16
    @NSManaged public var waiter: Int16
    @NSManaged public var timeWorkTimer: Int16
    @NSManaged public var timeStartOrder: Int16
    @NSManaged public var timeFiveMinutes: Int16
    @NSManaged public var open: Int16
    @NSManaged public var maxOrder: Int16
    @NSManaged public var maxDelay: Int16
    @NSManaged public var height: Int16
    @NSManaged public var countIterations: Int16
    @NSManaged public var cafe: Int16

}
