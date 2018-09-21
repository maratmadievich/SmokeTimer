//
//  SettingsView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 09.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol SettingsProtocol {
    func showAlertView(error: String)
    func getWaiters()
    var user: User { get }
    var jsonParser: JsonParser { get }
}

class SettingsView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SettingsProtocol {
    
    @IBOutlet weak var textFieldStartOrder: UITextField!
    @IBOutlet weak var textFieldFiveMinutes: UITextField!
    @IBOutlet weak var textFieldWorkTimer: UITextField!
    @IBOutlet weak var textFieldCountIterations: UITextField!
    @IBOutlet weak var textFieldOrderCount: UITextField!
    @IBOutlet weak var textFieldDelay: UITextField!
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    var delegate: AddWaiterProtocol?
    
    let urlString = UrlString()
    let jsonParser = JsonParser()
    
    var user = User()
    var selectedIndexPath: IndexPath?
    
    var waiters = [Waiter]()
    
    
    override func layoutSubviews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.addGestureRecognizer(tap)
        getWaiters()
        getSettings()
    }
    
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.waiters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (waiters[indexPath.row].id > 0) {
            let cell = Bundle.main.loadNibNamed("RowWaiterDesign", owner: self, options: nil)?.first as! TVCWaiterDesign
            cell.backgroundColor = UIColor.clear
            cell.delegateSettings = self
            cell.token = user.token
            cell.cafe = user.cafe
            cell.waiter = waiters[indexPath.row]
            cell.delegateAddWaiter = delegate
            cell.labelName.text = waiters[indexPath.row].name
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("RowAddWaiter", owner: self, options: nil)?.first as! TVCAddWaiter
            cell.backgroundColor = UIColor.clear
            cell.delegateAddWaiter = delegate
            return cell
        }
    }
    
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if (indexPath.row == waiters.count - 1) {
//            return 100.0 
//        }
//        return 70.0
//    }
    
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    
    @IBAction func btnAddClicked(_ sender: Any) {
        delegate?.addWaiter(waiter: Waiter())
    }
    
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        self.endEditing(true)
        checkTimerData()
    }
    
    
    
    // MARK: Работа с базой данных
    
    func getWaiters() {
        
        if (!Connectivity.isConnectedToInternet) {
            self.showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = self.user.token
            parameters["cafe"] = self.user.cafe
            
            Alamofire.request(urlString.getUrl() + "api/CafeWaiter",
                method: .post,
                parameters: parameters,
                encoding: JSONEncoding.default)
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        self.waiters.removeAll()
                        print("CafeWaiter_data: \(json)")
                            
                        if let waitersJson = json["success"].array {
                            for waiterJson in waitersJson {
                                let waiter = Waiter()
                                if let id = waiterJson["id"].int {
                                    print("id " + String(id))
                                    waiter.id = id
                                }
                                if let name = waiterJson["name"].string {
                                    print("name " + name)
                                    waiter.name = name
                                }
                                if let login = waiterJson["login"].string {
                                    print("login " + login)
                                    waiter.login = login
                                }
                                if let phone = waiterJson["phone"].string {
                                    print("phone " + String(phone))
                                    waiter.phone = phone
                                }
                                self.waiters.append(waiter)
                            }
                        }
                        self.tableView.reloadData()
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
        
//            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
//                self.waiters.append(Waiter())
//                self.tableView.reloadData()
//            }
            }
        }
    }
    
    
    func getSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = self.user.token
            parameters["cafe"] = self.user.cafe
            
            Alamofire.request(urlString.getUrl() + "api/CafeDetailed",
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default)
                .responseJSON {
                    response in
                    
                    switch response.result {
                    case .success(let value):
                        
                        let json = JSON(value)
                        print("CafeDetailed_data: \(json)")
                        
                        if let error = json["error"] as? String {
                            GlobalConstants.settings.error = error
                        } else {
                            if let data = json["success"].dictionary {
                                if let name = data["name"]?.string {
                                    GlobalConstants.settings.name = name
                                }
                                if let timeStartOrder = data["order_timer"]?.int {
                                    GlobalConstants.settings.timeStartOrder = timeStartOrder
                                }
                                if let timeFiveMinutes = data["minutes_timer"]?.int {
                                    GlobalConstants.settings.timeFiveMinutes = timeFiveMinutes
                                }
                                if let timeWorkTimer = data["work_timer"]?.int {
                                    GlobalConstants.settings.timeWorkTimer = timeWorkTimer
                                }
                                if let countIterations = data["timer_count"]?.int {
                                    GlobalConstants.settings.countIterations = countIterations
                                }
                                if let maxOrder = data["max_order"]?.int {
                                    GlobalConstants.settings.maxOrder = maxOrder
                                }
                                if let maxDelay = data["max_delay"]?.int {
                                    GlobalConstants.settings.maxDelay = maxDelay
                                }
                                if let height = data["height"]?.float {
                                    GlobalConstants.settings.height = CGFloat(height)
                                }
                                if let width = data["width"]?.float {
                                    GlobalConstants.settings.width = CGFloat(width)
                                }
                                if let open = data["open"]?.int {
                                    GlobalConstants.settings.open = open
                                }
                                if let waiter = data["waiter"]?.int {
                                    GlobalConstants.settings.waiter = waiter
                                }
                                if let workspace = data["workspace_count"]?.int {
                                    GlobalConstants.settings.workspaceCount = workspace
                                }
                                GlobalConstants.settings.cafe = GlobalConstants.user.cafe
                            }
                        }
                        self.setSettings()
                        break
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                        break
                    }
                    
                    //            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
                    //                response in
                    //                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
                    //                self.waiters.append(Waiter())
                    //                self.tableView.reloadData()
                    //            }
            }
            
//            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
//                if (self.settings.error.count > 0) {
////                    self.showEmptyFieldAlert(error: self.settings.error)
//                } else {
//                    self.textFieldStartOrder.text = String(self.settings.timeStartOrder)
//                    self.textFieldFiveMinutes.text = String(self.settings.timeFiveMinutes)
//                    self.textFieldWorkTimer.text = String(self.settings.timeWorkTimer)
//                    self.textFieldCountIterations.text = String(self.settings.countIterations)
//                    self.textFieldCountIterations.text = String(self.settings.countIterations)
//                    self.textFieldOrderCount.text = String(self.settings.maxOrder)
//                    self.textFieldDelay.text = String(self.settings.maxDelay)
//                }
//            }
        }
    }



private func setSettings() {
    self.textFieldStartOrder.text = String(GlobalConstants.settings.timeStartOrder)
    self.textFieldFiveMinutes.text = String(GlobalConstants.settings.timeFiveMinutes)
    self.textFieldWorkTimer.text = String(GlobalConstants.settings.timeWorkTimer)
    self.textFieldCountIterations.text = String(GlobalConstants.settings.countIterations)
    self.textFieldCountIterations.text = String(GlobalConstants.settings.countIterations)
    self.textFieldOrderCount.text = String(GlobalConstants.settings.maxOrder)
    self.textFieldDelay.text = String(GlobalConstants.settings.maxDelay)
}
    
    
    func checkTimerData() {
        if (textFieldStartOrder.text!.count == 0) {
            showAlertView(error: "Поле \"Таймер принятия заказа\" пустое")
        } else if (textFieldFiveMinutes.text!.count == 0) {
            showAlertView(error: "Поле \"Таймер 5 минут\" пустое")
        } else if (textFieldWorkTimer.text!.count == 0) {
            showAlertView(error: "Поле \"Таймер рабочий\" пустое")
        } else if (textFieldCountIterations.text!.count == 0) {
            showAlertView(error: "Поле \"Количество промежуточных таймеров\" пустое")
        } else if (textFieldOrderCount.text!.count == 0) {
            showAlertView(error: "Поле \"Количество заказов за 1 столик\" пустое")
        } else if (textFieldDelay.text!.count == 0) {
            showAlertView(error: "Поле \"Max. время просрочки таймера\" пустое")
        } else if (Int(textFieldStartOrder.text!)! < 1 ||
            Int(textFieldFiveMinutes.text!)! < 1 ||
            Int(textFieldWorkTimer.text!)! < 1 ||
            Int(textFieldCountIterations.text!)! < 1 ||
            Int(textFieldOrderCount.text!)! < 1 ||
            Int(textFieldDelay.text!)! < 1) {
            showAlertView(error: "Все значения должны быть больше 0")
        } else {
            saveSettings()
        }
    }
    
    
    func saveSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe": String(self.user.cafe),
                              "order_timer": textFieldStartOrder.text!,
                              "minutes_timer":  textFieldFiveMinutes.text!,
                              "work_timer":  textFieldWorkTimer.text!,
                              "timer_count":  textFieldCountIterations.text!,
                              "max_order":  textFieldOrderCount.text!,
                              "max_delay":  textFieldDelay.text!]
            request(urlString.getUrl() + "api/CafeUpdate", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.showAlertView(error: response.text)
                } else {
                    self.showAlertView(error: "Сохранение прошло успешно")
                }
            }
        }
    }
    
    func showAlertView(error: String) {
        labelAlert.text = error
        UIView.transition(with: viewAlert, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewAlert.isHidden = false
        })
        { (finished) in
            self.hiddenAlertView()
        }
    }
    
    
    func hiddenAlertView() {
        _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            UIView.transition(with: self.viewAlert, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.viewAlert.isHidden = true
            })
        }
    }
    
    
}
