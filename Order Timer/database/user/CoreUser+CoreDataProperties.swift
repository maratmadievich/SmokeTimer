//
//  CoreUser+CoreDataProperties.swift
//  Order Timer
//
//  Created by Марат Нургалиев on 27.06.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//
//

import Foundation
import CoreData


extension CoreUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoreUser> {
        return NSFetchRequest<CoreUser>(entityName: "CoreUser")
    }

    @NSManaged public var token: String?
    @NSManaged public var role: Int16
    @NSManaged public var phone: String?
    @NSManaged public var pass: String?
    @NSManaged public var name: String?
    @NSManaged public var login: String?
    @NSManaged public var id: Int16
    @NSManaged public var cafe: Int16

}
