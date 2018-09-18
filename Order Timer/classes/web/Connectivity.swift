//
//  Connectivity.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 15.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
