//
//  CoreTable+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreTable> {
        return NSFetchRequest<CoreTable>(entityName: "CoreTable")
    }

    @NSManaged public var y: Double
    @NSManaged public var x: Double
    @NSManaged public var name: String?
    @NSManaged public var id: Int16
    @NSManaged public var cafe: Int16

}
