//
//  CoreRequest+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreRequest {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreRequest> {
        return NSFetchRequest<CoreRequest>(entityName: "CoreRequest")
    }

    @NSManaged public var url: String?
    @NSManaged public var type: Int16
    @NSManaged public var id: Int16

}
