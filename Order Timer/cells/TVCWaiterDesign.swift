//
//  TVCTables.swift
//  Cafe Timer
//  Cafe

//  Created by Марат Нургалиев on 09.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class TVCWaiterDesign: UITableViewCell {

    @IBOutlet weak var cornerView: CornerView!
    @IBOutlet weak var viewEdit: UIView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    var delegateAddWaiter: AddWaiterProtocol?
    var delegateSettings: SettingsProtocol?
    
    let urlString = UrlString()
    
    var token = ""
    var cafe = 0
    var waiter = Waiter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
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
            delegateSettings?.showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = [String: String]()
            parameters["api_token"] = token
            parameters["cafe"] = String(cafe)
            parameters["user"] = String(waiter.id)
            
            request(urlString.getUrl() + "api/DeleteWaiter", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.delegateSettings?.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response?.isError)! {
                    self.delegateSettings?.showAlertView(error: (response?.text)!)
                } else {
                    self.delegateSettings?.getWaiters()
                }
            }
        }
    }

}
