//
//  TVCAddOrder.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 15.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class TVCAddOrder: UITableViewCell {

    var delegateAddOrder: AddOrderProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func btnAddClicked(_ sender: Any) {
        delegateAddOrder?.addOrder()
    }
    
}
