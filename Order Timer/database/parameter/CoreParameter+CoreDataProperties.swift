//
//  CoreParameter+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreParameter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreParameter> {
        return NSFetchRequest<CoreParameter>(entityName: "CoreParameter")
    }

    @NSManaged public var value: String?
    @NSManaged public var key: String?
    @NSManaged public var idRequest: Int16

}
