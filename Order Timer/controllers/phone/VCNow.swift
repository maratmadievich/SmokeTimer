//
//  VCNow.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 19.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class VCNow: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var viewWaiters: UIView!
    @IBOutlet weak var viewCafe: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelCurrentWaiter: UILabel!
    
    @IBOutlet weak var constraintWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    @IBOutlet weak var buttonCloseWork: UIButton!
    @IBOutlet weak var buttonChangeWaiter: UIButton!
    @IBOutlet weak var buttonShowWaiters: UIBarButtonItem!
    
    var isWaiterLoad = false
    var isShowWaiters = false
    var isSettingsLoad = false
    var selectedIndexPath = IndexPath()
    
    var orders = [Order]()
    var tables = [Table]()
    var waiters = [Waiter]()
    
    var timer = Timer()
    
    
    override func viewWillAppear(_ animated: Bool) {
        prepareGetWaiters()
        prepareGetSettings()
        GlobalConstants.currentViewController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
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
            buttonChangeWaiter.isEnabled = true
            selectedIndexPath = indexPath
        }
    }
    
    
    // MARK: Обработка нажатий
    
    @IBAction func btnCloseWorkClicked(_ sender: Any) {
        self.showWaitersView(isShow: false)
        self.prepareCloseWork()
    }
    
    
    @IBAction func btnChangeClicked(_ sender: Any) {
        self.prepareChangeWaiter()
    }
    
    
    @IBAction func btnShowWaitersClicked(_ sender: Any) {
         self.showWaitersView(isShow: !isShowWaiters)
    }
    
    
    // MARK: Работа с базой данных
    
    // Получение официантов
    func prepareGetWaiters() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getWaiters(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
//                self.isWaiterLoad = true
//                self.setWaiterText()
//                self.tableView.reloadData()
//            }
        }
    }
    
    
    // Получение настроек
    func prepareGetSettings() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getSettings(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
//                self.isSettingsLoad = true
//                if (self.settings.height >= 300
//                    && self.settings.width >= 300) {
//                    self.constraintHeight.constant = self.settings.height
//                    self.constraintWidth.constant = self.settings.width
//                } else {
//                    self.constraintHeight.constant = 300
//                    self.constraintWidth.constant = 300
//                }
//                self.setWaiterText()
//                self.getTables()
//            }
        }
    }
    
    
    // Получение списка таблиц
    func prepareGetTables() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getTables(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeTable", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.tables = self.jsonParser.parseTables(JSONData: response.data!, cafe: self.user.cafe)
//                if (self.tables.count > 0) {
//                    self.drawTables()
//                }
//                self.getOrder()
//            }
        }
    }
    
    
    // Получение списка заказов
    func prepareGetOrders() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getOrders(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeOrder", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.orders = self.jsonParser.parseOrder(JSONData: response.data!, cafe: self.user.cafe)
//
//                if (self.tables.count > 0) {
//                    self.setStatus()
//                }
//            }
        }
    }
    
    
    // Смена статуса заведения (Закрыть смену)
    func prepareCloseWork() {
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
//                    self.orders.removeAll()
//                    self.setStatus()
//                    self.setWaiterText()
//                }
//            }
        }
    }
    
    
    // Смена статуса заведения (Начать/закрыть смену)
    func prepareChangeWaiter() {
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
//                    self.setWaiterText()
//                }
//            }
        }
    }
    
    
    // MARK: Вспомогательные функции
    
    func showWaitersView(isShow: Bool) {
        if (isShow != isShowWaiters) {
            UIView.animate(withDuration: 0.5, animations: {
                if (isShow) {
                    self.viewWaiters.center.x -= self.view.bounds.width
                } else {
                    self.viewWaiters.center.x += self.view.bounds.width
                }
            })
            self.isShowWaiters = isShow
        }
    }
    
    
    // Установка
    func setWaiterText() {
        if (self.isWaiterLoad && self.isSettingsLoad) {
            buttonChangeWaiter.isEnabled = false
            if (GlobalConstants.settings.open > 0) {
                buttonCloseWork.isEnabled = true
                for waiter in self.waiters {
                    if (waiter.id == GlobalConstants.settings.waiter) {
                        labelCurrentWaiter.text = "Текущий официант: " + waiter.name
                        break
                    }
                }
            } else {
                buttonCloseWork.isEnabled = false
                buttonChangeWaiter.isEnabled = false
                labelCurrentWaiter.text = "Смена закрыта"
            }
        }
    }
    
    // Отрисовка столика на рабочей области
    func drawTables() {
        for table in self.tables {
            if let viewTable = Bundle.main.loadNibNamed("Table", owner: self, options: nil)?.first as? TableView {
                viewTable.borderColor = UIColor.lightGray
                viewTable.cornerRadius = 10
                viewTable.borderWidth = 1
                viewTable.tag = table.id + 100
                viewTable.backgroundColor = Table().getColor(status: 0)
                
                viewTable.labelName.text = table.name
                viewTable.labelCount.text = ""
                viewTable.labelTimer.text = ""
                viewTable.labelStatus.text = ""
                
                viewTable.frame.origin.x = table.x - 70
                viewTable.frame.origin.y = table.y - 70
                
                self.viewCafe.addSubview(viewTable)
            }
        }
    }
    
    
    // Смена статуса столиков
    func setStatus() {
        print("Статусы обновились")
        let currentDate = Date()
        for table in self.tables {
            if let viewWithTag: TableView = self.viewCafe.viewWithTag(table.id + 100) as? TableView{
                var status = 0
                var time = 0.0
                var count = 0
                var i = 0
                while i < self.orders.count {
                    if (self.orders[i].idTable == table.id) {
                        count += 1
                        if (time == 0) {
                            time = self.orders[i].time
                            status = self.orders[i].status
                        } else if (self.orders[i].time < time) {
                            time = self.orders[i].time
                            status = self.orders[i].status
                        }
                    }
                    i += 1
                }
                viewWithTag.backgroundColor = Table().getColor(status: status)
                switch status {
                case 0:
                    viewWithTag.labelCount.text = ""
                    viewWithTag.labelTimer.text = ""
                    viewWithTag.labelStatus.text = ""
                    viewWithTag.imageWarning.isHidden = true
                    break
                    
                case 1:
                    viewWithTag.labelStatus.text = "Принят заказ"
                    break
                    
                case 2:
                    viewWithTag.labelStatus.text = "Правило 5 минут"
                    break
                    
                default:
                    viewWithTag.labelStatus.text = "Рабочий таймер"
                    break
                }
                if (status > 0) {
                    viewWithTag.labelCount.text = "Заказов: " + String(describing: count)
                    var difference = Int(time - currentDate.timeIntervalSince1970)
                    if (difference > 0) {
                        let minutes = String (Int(difference / 60)) + " м "
                        let seconds = String (difference % 60) + " с"
                        viewWithTag.labelTimer.text = "Осталось " + minutes + seconds
                        viewWithTag.imageWarning.isHidden = true
                    } else {
                        difference = -difference
                        let minutes = Int(difference / 60)
                        let seconds = difference % 60
                        let stringMinutes = String (minutes) + " м "
                        let stringSeconds = String (seconds) + " с"
                        viewWithTag.labelTimer.text = "Прошло " + stringMinutes + stringSeconds
                        viewWithTag.imageWarning.isHidden = false
                    }
                }
            }
        }
    }
    
    
    // MARK: Алерты
    
    // Алерт для вывода разъяснительной информации
    func showEmptyFieldAlert(error: String) {
        let alert = UIAlertController(title: "Внимание", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Работа с таймером
    
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
//        timer = Timer.scheduledTimer(timeInterval: 30, target: self,   selector: (#selector(VCPWork.getOrder)), userInfo: nil, repeats: true)
    }
    

}

extension VCNow: BackEndWaitersProtocol {
    
    func returnMy(waiters: [Waiter]) {
        self.waiters = waiters
        self.isWaiterLoad = true
        self.setWaiterText()
        self.tableView.reloadData()
    }
    
    func returnChangeSuccess() {
        GlobalConstants.settings.waiter = self.waiters[self.selectedIndexPath.row].id
        self.tableView.deselectRow(at: self.selectedIndexPath, animated: true)
        self.setWaiterText()
    }
    
    func returnError(error: String) {
        showEmptyFieldAlert(error: error)
    }
    
    func returnAddSuccess() {}
    func returnUpdateSuccess() {}
    func returnDeleteSuccess() {}
    
}

extension VCNow: BackEndSettingsProtocol {
    
    func returnSettingsSuccess() {
        self.isSettingsLoad = true
        if (GlobalConstants.settings.height >= 300
            && GlobalConstants.settings.width >= 300) {
            self.constraintHeight.constant = GlobalConstants.settings.height
            self.constraintWidth.constant = GlobalConstants.settings.width
        } else {
            self.constraintHeight.constant = 300
            self.constraintWidth.constant = 300
        }
        self.setWaiterText()
        self.prepareGetTables()
    }
    
}

extension VCNow: BackEndTablesProtocol {
    
    func returnMy(tables: [Table]) {
        self.tables = tables
        if (self.tables.count > 0) {
            self.drawTables()
        }
        self.prepareGetOrders()
    }
    
    func returnAdd(table: Table) {}
    func returnDelete(table: Int) {}
    
}

extension VCNow: BackEndOrdersProtocol {
    func returnMy(orders: [Order]) {
        self.orders = orders
        if (self.tables.count > 0) {
            self.setStatus()
        }
    }
    
    func returnAdd(order: Order) {}
    func returnUpdate(order: Order) {}
    func returnDelete(order: Order) {}

}

extension VCNow: BackEndChangeOpenProtocol {
    
    func returnSuccess(isOpen: Bool) {
        GlobalConstants.settings.waiter = GlobalConstants.user.id
        GlobalConstants.settings.open = 0
        self.orders.removeAll()
        self.setStatus()
        self.setWaiterText()
    }
    
}

















