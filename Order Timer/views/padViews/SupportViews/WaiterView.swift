//
//  WaiterView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 09.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class WaiterView: UITableViewCell {

    @IBOutlet weak var cornerView: CornerView!
    @IBOutlet weak var viewEdit: UIView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    let urlString = UrlString()
    
    var delegateAddWaiter: AddWaiterProtocol?
    var delegateSettings: SettingsProtocol?
    
    var token = ""
    var cafe = 0
    var waiter = Waiter()
    
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        deleteWaiter()
    }
    
    
    @objc func tapView(_ gestureReconizer: UITapGestureRecognizer) {
        delegateAddWaiter?.addWaiter(waiter: waiter)
    }
    
    
    @IBAction func editWaiter(_ sender: Any) {
        delegateAddWaiter?.addWaiter(waiter: waiter)
    }
    
    
    func deleteWaiter() {
        if (!Connectivity.isConnectedToInternet) {
//            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = [String: String]()
            parameters["api_token"] = token
            parameters["cafe"] = String(cafe)
            parameters["user"] = String(waiter.id)
           
            request(urlString.getUrl() + "api/DeleteWaiter", method: .post, parameters: parameters).responseJSON {
                response in
                let response = GlobalConstants.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.delegateSettings?.showAlertView(error: response.text)
                } else {
                    self.delegateSettings?.prepareGetWaiters()
                }
            }
        }
    }
    
}
