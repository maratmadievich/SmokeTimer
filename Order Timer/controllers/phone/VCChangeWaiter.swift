//
//  VCChangeWaiter.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 31.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class VCChangeWaiter: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint2: NSLayoutConstraint!
    
    var selectedIndexPath = IndexPath()
    
    var waiters = [Waiter]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        prepareGetWaiters()
        GlobalConstants.currentViewController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        btnChange.isEnabled = false
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            bottomConstraint.constant = 40
            bottomConstraint2.constant = 40
        }
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.waiters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowWaiter", for: indexPath) as! TVCWaiter
        cell.labelName.text = waiters[indexPath.row].name
        return cell
    }
    
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (GlobalConstants.settings.open > 0 ) {
            btnChange.isEnabled = true
            selectedIndexPath = indexPath
        }
    }

    
    @IBAction func btnChangeCLicked(_ sender: Any) {
        self.changeWaiter()
    }
    
    
    @IBAction func btnCloseClicked(_ sender: Any) {
        self.closeWork()
    }
    
    
    // MARK: Работа с базой данных
    
    // Получение списка официантов
    func prepareGetWaiters() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getWaiters(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
//                self.tableView.reloadData()
//            }
        }
    }
    
    
    // Смена статуса заведения (Закрыть смену)
    func closeWork() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
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
//                    self.showEmptyFieldAlert(error: response.text)
//                } else {
//                    self.settings.waiter = self.user.id
//                    self.settings.open = 0
//                    let _ = self.navigationController?.popViewController(animated: true)
//                }
//            }
        }
    }
    
    
    // Смена статуса заведения (Начать/закрыть смену)
    func changeWaiter() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["waiter"] = self.waiters[self.selectedIndexPath.row].id
            GlobalConstants.alamofireResponse.changeWaiter(parameters: parameters, delegate: self)
            
            
//            request(urlString.getUrl() + "api/CafeChangeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                    self.showEmptyFieldAlert(error: response.text)
//                } else {
//                    self.settings.waiter = self.waiters[self.selectedIndexPath.row].id
//                    self.tableView.deselectRow(at: self.selectedIndexPath, animated: true)
//                }
//            }
        }
    }
    
    
    // MARK: Алерты
    
    // Алерт для вывода разъяснительной информации
    func showEmptyFieldAlert(error: String) {
        let alert = UIAlertController(title: "Внимание", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension VCChangeWaiter: BackEndWaitersProtocol {
    
    func returnAddSuccess() {}
    
    func returnUpdateSuccess() {}
    
    
    func returnMy(waiters: [Waiter]) {
        self.waiters = waiters
        self.tableView.reloadData()
    }
    
    func returnChangeSuccess() {
        GlobalConstants.settings.waiter = self.waiters[self.selectedIndexPath.row].id
        self.tableView.deselectRow(at: self.selectedIndexPath, animated: true)
    }
    
    func returnDeleteSuccess() {}
    
    func returnError(error: String) {
        showEmptyFieldAlert(error: error)
    }
    
}

extension VCChangeWaiter: BackEndChangeOpenProtocol {
    
    func returnSuccess(isOpen: Bool) {
        GlobalConstants.settings.waiter = GlobalConstants.user.id
        GlobalConstants.settings.open = 0
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
}






