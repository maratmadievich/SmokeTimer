//
//  VCNowTable.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 29.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications

class VCNowTable: UIViewController, UITableViewDelegate, UITableViewDataSource, AlertExitProtocol {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    var isFirst = true
    
    var timer = Timer()
    
    var tables = [Table]()
    var orders = [Order]()
    var fromAuth = false
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        prepareGetSettings()
        if (fromAuth) {
            let btn1 = UIButton(type: .custom)
            btn1.setTitle("Выйти", for: .normal)
            btn1.tintColor = UIColor.white
            btn1.addTarget(self, action: #selector(VCNowTable.btnExitClicked), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: btn1)
            
            self.navigationItem.setLeftBarButtonItems([item1], animated: false)
        }
        GlobalConstants.currentViewController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    
    @IBAction func btnExitClicked(_ sender: Any) {
        if let viewAlertExit = Bundle.main.loadNibNamed("AlertExit", owner: self, options: nil)?.first as? AlertExit {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAlertExit.frame = rect
            viewAlertExit.forPhone = true
            viewAlertExit.delegate = self
            view.addSubview(viewAlertExit)
        }
    }
    
    
    func responseExit(response: Int) {
        if (response > 0) {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowOrder", for: indexPath) as! TVCOrder
        cell.orderRow = indexPath.row
        cell.backgroundColor = UIColor.clear
        cell.time = orders[indexPath.row].time
        cell.status = orders[indexPath.row].status
        cell.tableName = orders[indexPath.row].tableName
        cell.orderNumber = orders[indexPath.row].cafeNumber
        return cell
    }
    
    
    // MARK: Работа с базой данных
    
    // Получение настроек
    @objc func prepareGetSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getSettings(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
//                if self.settings.open > 0 {
//                    self.getTables()
//                } else {
//                    self.deleteAllNotifications()
//                    self.tables.removeAll()
//                    self.tableView.reloadData()
//                    if (self.isFirst) {
//                        self.showAlertView(error: "Смена сейчас закрыта")
//                    }
//                }
//                self.isFirst = false
//            }
        }
    }
    
    
    // Получение списка таблиц
    func prepareGetTables() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getTables(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeTable", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.deleteAllNotifications()
//                self.tables = self.jsonParser.parseTables(JSONData: response.data!, cafe: self.user.cafe)
//                self.getOrder()
//            }
        }
    }
    
    
    // Получение списка заказов
    func prepareGetOrder() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getOrders(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeOrder", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.orders = self.jsonParser.parseOrder(JSONData: response.data!, cafe: self.user.cafe)
//                var i = 0
//                while (i < self.tables.count) {
//                    self.tables[i].orders.removeAll()
//                    for order in self.orders {
//                        if (self.tables[i].id == order.idTable) {
//                            order.tableName = self.tables[i].name
////                            self.tables[i].orders.append(order)
//                        }
//                    }
//                    i+=1
//                }
//                self.addAllNotifications()
//                self.tableView.reloadData()
//            }
        }
    }
    
    
    // Аналог onPause
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    // Аналог onResume
    override func viewDidAppear(_ animated: Bool) {
        runTimer()
    }
    
    
    // Запуск таймера на обновление рабочей области
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 15, target: self,   selector: (#selector(VCNowTable.prepareGetSettings)), userInfo: nil, repeats: true)
    }
    
    
    // MARK: Вывод уведомлений
    func showAlertView(error: String) {
        labelAlert.text = error
        UIView.transition(with: viewAlert, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.viewAlert.isHidden = false
        })
        { (finished) in
            self.hiddenAlertView()
        }
    }
    
    
    private func hiddenAlertView() {
        _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            UIView.transition(with: self.viewAlert, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.viewAlert.isHidden = true
            })
        }
    }
    
    
    
    // Удаление уведомления
    func deleteAllNotifications () {
        let center = UNUserNotificationCenter.current()
        for table in tables {
            for order in table.orders {
                center.removePendingNotificationRequests(withIdentifiers: [String(order.id)])
            }
        }
    }
    
    
    func addAllNotifications () {
        let center = UNUserNotificationCenter.current()
//        for table in tables {
            for order in orders {
                let content = UNMutableNotificationContent()
//                content.title = "Нужно вернуться к столику \"" + order.tableName + "\" Заказ № " + String(order.cafeNumber)
                content.title = "\"" + order.tableName + "\""
                content.body = ""
                content.sound = UNNotificationSound.default()
                        
                let calendar = Calendar(identifier: .gregorian)
                let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: order.time))
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: String(order.id), content: content, trigger: trigger)
                center.add(request, withCompletionHandler: nil)
            }
//        }
    }
    
    
}

extension VCNowTable: BackEndSettingsProtocol {
    
    func returnUpdateSuccess() {}
    
    func returnSettingsSuccess() {
        if GlobalConstants.settings.open > 0 {
            self.prepareGetTables()
        } else {
            self.deleteAllNotifications()
            self.tables.removeAll()
            self.tableView.reloadData()
            if (self.isFirst) {
                self.showAlertView(error: "Смена сейчас закрыта")
            }
        }
        self.isFirst = false
    }
    
    func returnError(error: String) {
        showAlertView(error: error)
    }
    
}

extension VCNowTable: BackEndTablesProtocol {
    
    func returnAdd(table: Table) {}
    func returnDelete(table: Int) {}
    
    
    func returnMy(tables: [Table]) {
        self.deleteAllNotifications()
        self.tables = tables
        self.prepareGetOrder()
    }

}

extension VCNowTable: BackEndOrdersProtocol {
    func returnMy(orders: [Order]) {
        self.orders = orders
        var i = 0
        while (i < self.tables.count) {
            self.tables[i].orders.removeAll()
            for order in self.orders {
                if (self.tables[i].id == order.idTable) {
                    order.tableName = self.tables[i].name
                }
            }
            i+=1
        }
        self.addAllNotifications()
        self.tableView.reloadData()
    }
    
    func returnAdd(order: Order) {}
    func returnUpdate(order: Order) {}
    func returnDelete(order: Order) {}
    
}











