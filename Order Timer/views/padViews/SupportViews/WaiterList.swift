//
//  WaiterList.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 04.05.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class WaiterList: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnCloseWork: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: NowProtocol?
    
    var waiters = [Waiter]()
    
    var isWaitersLoad = false
    var isSettingsLoad = false
    
    var selectedRow = -1
    
    
    override func layoutSubviews() {
        
    }
    
    
    func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        prepareGetSettings()
        prepareGetWaiters()
    }
    
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        if (GlobalConstants.settings.open > 0) {
            prepareCloseWork()
        }
    }
    
    

    // MARK: Работа с базой данных
    
    func prepareGetWaiters() {
        if (!Connectivity.isConnectedToInternet) {
            self.delegate?.nowShowAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getWaiters(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
//                self.isWaitersLoad = true
//                self.showWaiters()
//            }
        }
    }
    
    
    func prepareGetSettings() {
        if (!Connectivity.isConnectedToInternet) {
             self.delegate?.nowShowAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getSettings(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
//                self.isSettingsLoad = true
//                self.showWaiters()
//            }
        }
    }
    
    
    func prepareChangeWaiter(id: Int) {
        if (!Connectivity.isConnectedToInternet) {
             self.delegate?.nowShowAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["waiter"] = id
            GlobalConstants.alamofireResponse.changeWaiter(parameters: parameters, delegate: self)
            
//            request(urlString.getUrl() + "api/CafeChangeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                     self.delegate?.nowShowAlert(error: response.text)
//                } else {
//                    self.settings.waiter = id
//                    self.tableView.reloadData()
//                }
//            }
        }
    }
    
    
    func prepareCloseWork() {
        if (!Connectivity.isConnectedToInternet) {
             self.delegate?.nowShowAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.changeOpen(isOpen: true, delegate: self)
//            var parameters = [String: String]()
//            parameters["api_token"] = self.user.token
//            parameters["cafe"] = String(self.user.cafe)
//            parameters["waiter"] = String(self.user.id)
//            parameters["open"] = "0"
//
//            request(urlString.getUrl() + "api/CafeChangeOpen", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                     self.delegate?.nowShowAlert(error: response.text)
//
//                } else {
//                    self.settings.waiter = self.user.id
//                    self.settings.open = 0
//                    self.tableView.reloadData()
//                    self.delegate?.nowCloseWork()
//                }
//            }
        }
    }
   
    
    func showWaiters() {
        if (isSettingsLoad && isWaitersLoad) {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.waiters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RowWaiter", owner: self, options: nil)?.first as! TVCWaiter
        cell.backgroundColor = UIColor.clear
        if (GlobalConstants.settings.open > 0 && GlobalConstants.settings.waiter == waiters[indexPath.row].id) {
            cell.viewMain.backgroundColor = Table().getColor(status: 1)
        } else {
            cell.viewMain.backgroundColor = UIColor(red: 15/255, green: 15/255, blue: 15/255, alpha: 1)
        }
        cell.labelName.text = waiters[indexPath.row].name
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if (indexPath.row == waiters.count - 1) {
//            return 100.0
//        }
//        return 70.0
//    }
    
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (waiters[indexPath.row].id > 0 && GlobalConstants.settings.open > 0 && GlobalConstants.settings.waiter != waiters[indexPath.row].id) {
            self.selectedRow = indexPath.row
            prepareChangeWaiter(id: waiters[indexPath.row].id)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension WaiterList: BackEndSettingsProtocol {
    
    func returnSettingsSuccess() {
        self.isSettingsLoad = true
        self.showWaiters()
    }
    
    func returnUpdateSuccess() {}
    
    func returnError(error: String) {
        self.delegate?.nowShowAlert(error: error)
    }
    
    
}

extension WaiterList: BackEndWaitersProtocol {
    
    func returnMy(waiters: [Waiter]) {
        self.waiters = waiters
        self.isWaitersLoad = true
        self.showWaiters()
    }
    
    func returnAddSuccess() {}
    
    func returnChangeSuccess() {
        GlobalConstants.settings.waiter = waiters[selectedRow].id
        self.tableView.reloadData()
    }
    
    func returnDeleteSuccess() {}
    
}

extension WaiterList: BackEndChangeOpenProtocol {
    
    func returnSuccess(isOpen: Bool) {
        GlobalConstants.settings.waiter = GlobalConstants.user.id
        GlobalConstants.settings.open = 0
        self.tableView.reloadData()
        self.delegate?.nowCloseWork()
    }
    
    
}







