//
//  TVCAddWaiter.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 14.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class TVCAddWaiter: UITableViewCell {

    @IBOutlet weak var viewButton: CornerView!
    var delegateAddWaiter: AddWaiterProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func btnAddWaiterClicked(_ sender: Any) {
         delegateAddWaiter?.addWaiter(waiter: Waiter())
    }
    
    
    
}
