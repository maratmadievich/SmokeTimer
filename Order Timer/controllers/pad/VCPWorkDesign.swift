//
//  VCPWorkDesign.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 03.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications


protocol AddOrderProtocol {
    func addOrder()
}


protocol UpdateOrderProtocol {
    func updateOrder(orderRow: Int)
}


protocol AlertFiveOrderProtocol {
    func responseAlertFive(response: Int, tableRow: Int, orderRow: Int)
    func responseAlertChangeTable(response: Int, tableRow: Int)
}


protocol AlertExitProtocol {
    func responseExit(response: Int)
}






class VCPWorkDesign: UIViewController, UIScrollViewDelegate, CAAnimationDelegate, UITableViewDelegate, UITableViewDataSource, AddOrderProtocol, UpdateOrderProtocol, AlertFiveOrderProtocol, AlertExitProtocol {

    @IBOutlet weak var buttonStart: UIBarButtonItem!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    //View для работы с заказами
    @IBOutlet weak var viewOrder: UIView!
    @IBOutlet weak var viewOrderTable: CornerView!
    
    @IBOutlet weak var btnOrderReplace: ButtonCornerView!
    @IBOutlet weak var btnOrderRemove: ButtonCornerView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTableName: UILabel!

    
    let urlString = UrlString()
    let jsonParser = JsonParser()
    let coreDataParser = CoreDataParser()
    
    var user = User()
    var settings = Settings()
    
    var tables = [Table]()
    var requests = [Request]()
    
    var maxTimeId = 0;
    var timer = Timer()
    var timerUpload = Timer()
    var timerSettings = Timer()
    
    var oldTableRow = -1
    var isChangeTable = false
    var fromNet = false
    
    var pageCount: CGFloat = 1
    
    var tableWidth: CGFloat = 0
    var tableHeight: CGFloat = 0
    var minDistance: CGFloat = 0
    
    var selectedTable = -1
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        requests = coreDataParser.getRequests()
        setTableSize()
        getSettings(needTables: true)
        self.title = user.cafeName + " - Рабочая смена"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor(red: 33.0/255.0, green: 33.0/255.0, blue: 33.0/255.0, alpha: 1.0)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (selectedTable >= 0) {
            if (self.tables[selectedTable].orders.count == settings.maxOrder) {
                return settings.maxOrder
            }
            return self.tables[selectedTable].orders.count + 1
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (selectedTable >= 0) {
            if indexPath.row < tables[selectedTable].orders.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RowOrder", for: indexPath) as! TVCOrder
                cell.backgroundColor = UIColor.clear
                cell.delegateUpdateOrder = self
                cell.orderRow = indexPath.row
                cell.time = tables[selectedTable].orders[indexPath.row].time
                cell.status = tables[selectedTable].orders[indexPath.row].status
                cell.orderNumber = tables[selectedTable].orders[indexPath.row].cafeNumber
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RowAddOrder", for: indexPath) as! TVCAddOrder
                cell.backgroundColor = UIColor.clear
                cell.delegateAddOrder = self
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RowAddOrder", for: indexPath) as! TVCAddOrder
            cell.backgroundColor = UIColor.clear
            cell.delegateAddOrder = self
            return cell
        }
       
    }
    
    
    // Функции управляющего блока
    func addOrder() {
        self.clearSelectedTable()
        self.createNewOrder(tableRow: selectedTable)
        self.tableView.reloadData()
    }
    
    
    func updateOrder(orderRow: Int) {
        self.clearSelectedTable()
        self.checkTimerOrder(tableRow: selectedTable, orderRow: orderRow)
        self.tableView.reloadData()
    }
    
    
    func responseAlertFive(response: Int, tableRow: Int, orderRow: Int) {
        switch response {
        case 0:
            updateOrder(tableRow: tableRow, orderRow: orderRow, status: self.tables[tableRow].orders[orderRow].status + 1)
            break
            
        case 1:
            updateOrder(tableRow: tableRow, orderRow: orderRow, status: 1)
            break
            
        default:
            deleteOrder(tableRow: tableRow, orderRow: orderRow)
            break
        }
        tableView.reloadData()
    }
    
    
    func responseAlertChangeTable(response: Int, tableRow: Int) {
        switch response {
        case 0:
            changeTableOrders(tableRow: tableRow)
            btnOrderReplace.setTitle("Перенести", for: .normal)
            break
            
        case 1:
            break
            
        default:
            self.clearSelectedTable()
            btnOrderReplace.setTitle("Перенести", for: .normal)
            break
        }
        tableView.reloadData()
    }
    
    
    func responseExit(response: Int) {
        if (response > 0) {
            _ = navigationController?.popViewController(animated: true)
        }
    }
   
    
    @IBAction func btnReplaceClicked(_ sender: Any) {
        if (isChangeTable) {
            isChangeTable = false
            btnOrderReplace.setTitle("Перенести", for: .normal)
        } else if (tables[selectedTable].orders.count > 0) {
            self.isChangeTable = true
            self.oldTableRow = selectedTable
            btnOrderReplace.setTitle("Отмена", for: .normal)
        }
    }
    
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        if (tables[selectedTable].orders.count > 0) {
            self.clearSelectedTable()
            self.deleteTableOrders(tableRow: selectedTable)
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func btnExitClicked(_ sender: Any) {
        if let viewAlertExit = Bundle.main.loadNibNamed("AlertExit", owner: self, options: nil)?.first as? AlertExit {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAlertExit.frame = rect
            viewAlertExit.delegate = self
            view.addSubview(viewAlertExit)
        }
    }
    
    
    
    // MARK: Работа со скроллом
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewWidth: CGFloat = scrollView.frame.size.width
        let pageNumber = floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc func pageChanged() {
        let pageNumber = pageControl.currentPage
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    
    func loadScrollView() {
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        var pageCount: CGFloat = CGFloat(self.settings.workspaceCount)
        if pageCount < 1 {
            pageCount = 1
        }
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * pageCount, height:  scrollView.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        
        pageControl.numberOfPages = Int(pageCount)
        pageControl.addTarget(self, action: #selector(self.pageChanged), for: .valueChanged)
        
        for i in 0..<Int(pageCount) {
            print(self.scrollView.frame.size.width)
            let workspace = UIView()
            workspace.tag = -(i + 1)
            print ("Ширина scrollView: \(self.scrollView.frame.size.width)")
            print ("Длина scrollView: \(self.scrollView.frame.size.height)")
            
            let rect = CGRect(origin: CGPoint(x: self.scrollView.frame.size.width * CGFloat(i), y: 0), size: CGSize(width:self.scrollView.frame.size.width, height:self.scrollView.frame.size.height))
            workspace.frame = rect
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapViewCafe(_:)))
            workspace.addGestureRecognizer(tap)
            self.scrollView.addSubview(workspace)
        }
        
        for table in self.tables {
            drawTable(table: table)
        }
    }
    
    
    // MARK: Нажатие кнопок
    
    // Нажатие кнопки "Начать/Закрыть смену"
    @IBAction func btnStartClicked(_ sender: Any) {
        changeWaiterWork(isOpen: settings.open > 0)
    }
    
    
    // Нажатие на рабочую область
    @objc func tapViewCafe(_ gestureReconizer: UITapGestureRecognizer) {
        if (settings.open > 0) {
            if (self.settings.waiter == self.user.id) {
                for view in self.scrollView.subviews {
                    if view.tag == gestureReconizer.view?.tag {
                        let tapPoint = gestureReconizer.location(in: view)
                        let row = checkHaveTable(workspace: -view.tag, x: tapPoint.x, y: tapPoint.y)
                        selectedTable = row
                        if (row >= 0) {
                            labelTableName.text = tables[selectedTable].name
                            tableView.reloadData()
                            viewOrder.isHidden = false
                            
                            // Если происходит перенос заказов
                            if (isChangeTable) {
                                if (row == self.oldTableRow) {
                                    showAlertView(error: "Перенесение заказов на один и тот же столик невозможно")
                                } else {
                                    if (tables[oldTableRow].orders.count + tables[row].orders.count > settings.maxOrder) {
                                        showAlertView(error: "Невозможно перенести заказы. < Будет превышено максимальное число заказов на столике")
                                    } else {
                                        let text = "Вы действительно хотите перенести заказы из \'" + tables[self.oldTableRow].name + "\' на \'" + self.tables[row].name + "\'"
                                        showAlertFive(text: text, tableRow: row, orderRow: -1, typeWork: 1)
                                    }
                                }
                            }
                                // Если происходит первое нажатие на столик
                            else {
                                if (tables[selectedTable].orders.count == 0) {
                                    addOrder()
                                }
                                // Получение всех заказов
//                                showStartOrderAlert(tableRow: row)
                            }
                        } else {
                            viewOrder.isHidden = true
                        }
                        break
                    }
                }
            } else {
                showAlertView(error: "В данный момент смена открыта другим Официантом")
            }
        } else {
            showAlertView(error: "Для создания заказов необходимо нажать кнопку \"Начать смену\"")
        }
    }
    
    
    // MARK: Работа с базой данных
    
    // Получение настроек
    func getSettings(needTables: Bool) {
        if (!Connectivity.isConnectedToInternet) {
            if (needTables) {
                showAlertView(error: "Отсутствует соедиенение с Интернетом")
            }
        } else {
            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
                response in
                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
                self.coreDataParser.saveSettings(settings: self.settings)
                if (self.settings.open == 0) {
                    self.deleteAllNotifications()
                    self.coreDataParser.deleteOrder(cafe: self.user.cafe)
                    for table in self.tables {
                        table.orders.removeAll()
                    }
                    self.changeButtonValue()
                }
                if (needTables) {
                    self.changeButtonValue()
                    self.getTables()
                }
            }
        }
    }
    
    
    // Получение списка таблиц
    func getTables() {
        if (!Connectivity.isConnectedToInternet || !fromNet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
            tables = coreDataParser.getTables(cafe: self.user.cafe)
            loadScrollView()
            self.getOrder()
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe":String(self.user.cafe)]
            print ("getTables")
            request(urlString.getUrl() + "api/CafeTable", method: .post, parameters: parameters).responseJSON {
                response in
                self.tables = self.jsonParser.parseTables(JSONData: response.data!, cafe: self.user.cafe)
                if (self.tables.count > 0) {
                    self.coreDataParser.deleteTables(cafe: self.user.cafe)
                    self.coreDataParser.saveTables(tables: self.tables)
                }
                self.loadScrollView()
                self.getOrder()
            }
        }
    }
    
    
    // Получение списка заказов
    func getOrder() {
        if (!Connectivity.isConnectedToInternet || !fromNet) {
            self.mergeOrders(webOrders: [Order]())
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe":String(self.user.cafe)]
            print ("getOrder")
            request(urlString.getUrl() + "api/CafeOrder", method: .post, parameters: parameters).responseJSON {
                response in
                let orders = self.jsonParser.parseOrder(JSONData: response.data!, cafe: self.user.cafe)
                
                // НУЖНО: добавить ввод обстановки из локальной бд
                self.mergeOrders(webOrders: orders)
                
                if (self.tables.count > 0) {
                    self.setStatus()
                }
            }
        }
    }
    
    
    func mergeOrders(webOrders: [Order]) {
        var orders = webOrders
        let localOrders = coreDataParser.getOrders(cafe: self.user.cafe)
        if (orders.count > 0) {
            for localOrder in localOrders {
                if (localOrder.id < 0) {
                    if (localOrder.needUpdate != 2) {
                        orders.append(localOrder)
                    }
                } else {
                    var i = 0
                    while (i < orders.count) {
                        if (orders[i].id == localOrder.id) {
                            switch localOrder.needUpdate {
                            case 1:
                                orders[i] = localOrder
                                break
                            case 2:
                                orders.remove(at: i)
                                i-=1
                                break
                            default:
                                break
                            }
                        }
                        i+=1
                    }
                }
            }
        } else {
            for localOrder in localOrders {
                if (localOrder.needUpdate != 2) {
                    orders.append(localOrder)
                }
            }
        }
        
        //Поиск максимального временного таймера
        for order in orders {
            if (order.timeId > self.maxTimeId) {
                self.maxTimeId = order.timeId
            }
            for table in self.tables {
                if order.idTable == table.id {
                    table.orders.append(order)
                    break
                }
            }
        }
    }
    
    
    // Смена статуса заведения (Начать/закрыть смену)
    func changeWaiterWork(isOpen: Bool) {
        print ("changeWaiterWork")
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = [String: String]()
            parameters["api_token"] = self.user.token
            parameters["cafe"] = String(self.user.cafe)
            parameters["waiter"] = String(self.user.id)
            if (isOpen) {
                parameters["open"] = "0"
            } else {
                parameters["open"] = "1"
            }
            request(urlString.getUrl() + "api/CafeChangeOpen", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.showAlertView(error: response.text)
                } else {
                    self.settings.waiter = self.user.id
                    if (isOpen) {
                        self.settings.open = 0
                        self.deleteAllNotifications()
                        self.coreDataParser.deleteOrder(cafe: self.user.cafe)
                        for table in self.tables {
                            table.orders.removeAll()
                        }
                        self.viewOrder.isHidden = true
                        self.tableView.reloadData()
                        self.setStatus()
                    } else {
                        self.settings.open = 1
                    }
                    self.changeButtonValue()
                }
            }
        }
    }
    
    
    // Создание нового заказа
    func createNewOrder(tableRow: Int) {
        let timeInterval = Double(self.settings.timeStartOrder * 60)
        let date = Date(timeIntervalSinceNow: timeInterval)
        
        var cafeNumber = 0
        if (tables[tableRow].orders.count > 0) {
            for curOrder in tables[tableRow].orders {
                if (curOrder.cafeNumber > cafeNumber) {
                    cafeNumber = curOrder.cafeNumber
                }
            }
            cafeNumber = cafeNumber + 1
        } else {
            cafeNumber = 1
        }
        
        let order = Order()
        
        order.status = 1
        order.time = date.timeIntervalSince1970
        order.delay_flag = 0
        order.cafe = self.user.cafe
        order.idTable = self.tables[tableRow].id
        order.needUpdate = 1
        order.cafeNumber = cafeNumber
        print ("Max timer id = \(self.maxTimeId)")
        order.timeId = self.maxTimeId + 1
        self.maxTimeId += 1
        
        
        tables[tableRow].orders.append(order)
        coreDataParser.saveOrder(order: order)
        
        self.addNotification(order: order)
        //        self.deleteAllNotifications()
        //        self.addAllNotifications()
        
        self.setStatus()
    }
    
    
    // Изменение заказа
    func updateOrder(tableRow: Int, orderRow: Int, status: Int) {
        let order = self.tables[tableRow].orders[orderRow]
        self.deleteNotification(order: order)
        
        var timeInterval = Double(self.settings.timeStartOrder * 60)
        if (status == 2) {
            timeInterval = Double(self.settings.timeFiveMinutes * 60)
        } else if (status > 2) {
            timeInterval = Double(self.settings.timeWorkTimer * 60)
        }
        let date = Date(timeIntervalSinceNow: timeInterval)
        
        order.status = status
        order.time = date.timeIntervalSince1970
        order.delay_flag = 0
        order.idTable = self.tables[tableRow].id
        order.needUpdate = 1
        
        self.tables[tableRow].orders[orderRow] = order
        self.coreDataParser.updateOrder(order: order)
        
        self.addNotification(order: order)
        //        self.deleteAllNotifications()
        //        self.addAllNotifications()
        self.setStatus()
    }
    
    
    // Изменение столика у заказов
    func changeTableOrders(tableRow: Int) {
        var maxNumber = self.coreDataParser.getMaxOrderNumber(idTable: tables[tableRow].id)
        var i = 0
        
        while (i < tables[self.oldTableRow].orders.count) {
            self.deleteNotification(order: tables[self.oldTableRow].orders[i])
            maxNumber += 1
            tables[self.oldTableRow].orders[i].needUpdate = 1
            tables[self.oldTableRow].orders[i].idTable = tables[tableRow].id
            tables[self.oldTableRow].orders[i].cafeNumber = maxNumber
            tables[tableRow].orders.append(tables[self.oldTableRow].orders[i])
            self.coreDataParser.updateOrder(order: tables[self.oldTableRow].orders[i])
            self.addNotification(order: tables[self.oldTableRow].orders[i])
            i+=1
        }
        
        tables[self.oldTableRow].orders.removeAll()
        
//        while (i < orders.count) {
//            if (orders[i].idTable == self.tables[self.oldTableRow].id) {
//                self.deleteNotification(order: orders[i])
//                maxNumber += 1
//                orders[i].needUpdate = 1
//                orders[i].idTable = tables[tableRow].id
//                orders[i].cafeNumber = maxNumber
//                self.coreDataParser.updateOrder(order: orders[i])
//                self.addNotification(order: orders[i])
//            }
//            i+=1
//        }
        //        self.deleteAllNotifications()
        //        self.addAllNotifications()
        
        self.clearSelectedTable()
        self.setStatus()
    }
    
    
    // Изменение статуса делея
    func updateOrderDelay(tableRow: Int, orderRow: Int) {
        self.tables[tableRow].orders[orderRow].delay_flag = 1
        self.tables[tableRow].orders[orderRow].needUpdate = 1
        self.coreDataParser.updateOrder(order: self.tables[tableRow].orders[orderRow])
    }
    
    
    // Удаление заказа
    func deleteOrder(tableRow: Int, orderRow: Int) {
        self.tables[tableRow].orders[orderRow].needUpdate = 2
        self.coreDataParser.updateOrder(order: self.tables[tableRow].orders[orderRow])
        self.deleteNotification(order: self.tables[tableRow].orders[orderRow])
        //        self.deleteAllNotifications()
        //        self.addAllNotifications()
        self.tables[tableRow].orders.remove(at: orderRow)
        self.setStatus()
    }
    
    
    // Удаление всех заказов на столике
    func deleteTableOrders(tableRow: Int) {
//        var i = tables[tableRow].orders.count - 1
//
//        while (i > -1) {
//            tables[tableRow].orders[i].needUpdate = 2
//            self.deleteNotification(order: tables[tableRow].orders[i])
//            self.coreDataParser.updateOrder(order: tables[tableRow].orders[i])
//            tables[tableRow].orders.remove(at: i)
//            i -= 1
//        }
        for order in tables[tableRow].orders {
            self.deleteNotification(order: order)
        }
        self.coreDataParser.updateDeleteOrders(tableRow: tables[tableRow].id)
        tables[tableRow].orders.removeAll()
        self.setStatus()
    }
    
    
    // Создание нового косяка
    func addDelay(tableRow: Int, orderRow: Int) {
        var id = 1
        let localDelays = coreDataParser.getDelays()
        for delay in localDelays {
            if (delay.id > id) {
                id = delay.id
            }
        }
        id += 1
        let delay = Delay()
        let date = Date()
        delay.id = id
        delay.waiter = self.user.id
        delay.date = date.timeIntervalSince1970
        delay.cafe = self.user.cafe
        self.coreDataParser.saveDelay(delay: delay)
        self.updateOrderDelay(tableRow: tableRow, orderRow: orderRow)
    }
    
    
    // MARK: Вспомогательные функции
    
    // Установка размеров столиков
    func setTableSize() {
        self.tableWidth = (self.view.frame.size.width * 2) / 30
        self.tableHeight = (self.view.frame.size.width * 2) / 30
        self.minDistance = (self.view.frame.size.width * 2) / 300
    }
    
    
    // Отрисовка столика на рабочей области
    private func drawTable(table: Table) {
        var viewTable = Bundle.main.loadNibNamed("TableLong", owner: self, options: nil)?.first as! NewTableView
        if (table.size == 0) {
            viewTable = Bundle.main.loadNibNamed("NewTable", owner: self, options: nil)?.first as! NewTableView
        } else {
            viewTable.isTableLong = true
        }
        
        viewTable.tag = table.id + 100
        let tableX = table.x * self.scrollView.frame.size.width
        let tableY = table.y * self.scrollView.frame.size.height
        
        var currentWidth = tableWidth * 2
        var currentHeight = tableHeight * 2
        if (table.size > 0) {
            currentHeight = table.size * self.scrollView.frame.size.height
        } else if (table.size < 0) {
            currentWidth = -table.size * self.scrollView.frame.size.width
        }
        
        let rect = CGRect(origin: CGPoint(x: tableX - self.tableWidth, y: tableY - self.tableHeight), size: CGSize(width: currentWidth, height: currentHeight))
        viewTable.frame = rect
        viewTable.viewWidth = currentWidth
        viewTable.viewHeight = currentHeight
        
        viewTable.labelTableName.text = table.name
        viewTable.labelOrderCount.text = "0"
        
        var center = CGPoint(x: (viewTable.frame.width - 30) / 2, y: ((viewTable.frame.width - 30) / 2) + 30)
        var cornerRadius = (viewTable.frame.width - 30) / 2 - 4
        
        if (currentWidth > currentHeight) {
            center = CGPoint(x: (currentHeight - 30) / 2, y: ((currentHeight - 30) / 2) + 30)
            cornerRadius = (currentHeight - 30) / 2 - 4
        } else if (currentWidth < currentHeight) {
            center = CGPoint(x: (currentWidth - 30) / 2, y: ((currentWidth - 30) / 2) + 30)
            cornerRadius = (currentWidth - 30) / 2 - 4
        }
        
       
        //viewTable.table.center
        let circularPath = UIBezierPath(arcCenter: center, radius: cornerRadius, startAngle: -CGFloat.pi / 2, endAngle: (2 * CGFloat.pi) - (CGFloat.pi / 2), clockwise: true)
        viewTable.shapeLayer.path = circularPath.cgPath
        viewTable.shapeLayer.strokeColor = UIColor.black.cgColor
        
        viewTable.shapeLayer.fillColor = UIColor.clear.cgColor
        
        viewTable.shapeLayer.lineWidth = 2.5
        viewTable.shapeLayer.strokeEnd = 0
        viewTable.layer.addSublayer(viewTable.shapeLayer)

        
        scrollView.viewWithTag(-table.workspace)?.addSubview(viewTable)
    }
    
    
    // Проверка наличия столика
    // в месте нажатия на рабочую область
    private func checkHaveTable(workspace: Int, x: CGFloat, y: CGFloat) -> Int {
        var i = 0
        while (i < tables.count) {
            if (tables[i].workspace == workspace) {
                let tableX = tables[i].x * self.scrollView.frame.size.width
                let tableY = tables[i].y * self.scrollView.frame.size.height
                
                let oldX1 = tableX - tableWidth
                var oldX2 = tableX + tableWidth
                if (tables[i].size < 0) {
                    let size = -tables[i].size * scrollView.frame.size.width - tableWidth
                    oldX2 = tableX + size
                }
                let oldY1 = tableY - tableHeight
                var oldY2 = tableY + tableHeight
                if (tables[i].size > 0) {
                    let size = tables[i].size * scrollView.frame.size.height - tableWidth
                    oldY2 = tableY + size
                }
                var byX = false
                var byY = false
                if (oldX1 <= x && oldX2 >= x) {
                    byX = true
                }
                if (byX) {
                    if (oldY1 <= y && oldY2 >= y) {
                        byY = true
                    }
                }
                if (byX && byY) {
                    return i
                }
            }
            i += 1
        }
        return -1
    }
    
    
    // Смена текста кнопки
    func changeButtonValue() {
        if (self.settings.open == 0) {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                self.buttonStart.title = "Начать смену"
            } else {
                self.buttonStart.title = "Начать"
            }
        } else {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                self.buttonStart.title = "Закрыть смену"
            } else {
                self.buttonStart.title = "Закрыть"
            }
        }
    }
    
    
    // Смена статуса столиков
    func setStatus() {
        print("Статусы обновились")
        let currentDate = Date()
        for table in self.tables {
            if let viewWithTag: NewTableView = scrollView.viewWithTag(-table.workspace)?.viewWithTag(table.id + 100) as? NewTableView {
                var status = 0
                var time = 0.0
                var timerTime = 0.0
                for order in table.orders {
                    if (time == 0) {
                        time = order.time
                        status = order.status
                    } else if (order.time < time) {
                        time = order.time
                        status = order.status
                    }
                }
                viewWithTag.table.backgroundColor = Table().getColor(status: status)
                viewWithTag.order.backgroundColor = Table().getColor(status: 0)
                viewWithTag.labelOrderCount.text = String(table.orders.count)
                viewWithTag.time = time
                viewWithTag.checkTimer()
                switch status {
                case 0:
                    viewWithTag.shapeLayer.removeAllAnimations()
                    break
                    
                case 1:
                    timerTime = Double(self.settings.timeStartOrder) * 60.0
                    break
                    
                case 2:
                    timerTime = Double(self.settings.timeFiveMinutes) * 60.0
                    break
                    
                default:
                    timerTime = Double(self.settings.timeWorkTimer) * 60.0
                    break
                }
                if (table.orders.count > 1) {
                    viewWithTag.order.isHidden = false
                } else {
                    viewWithTag.order.isHidden = true
                }
                if (status > 0) {
                    viewWithTag.shapeLayer.removeAllAnimations()
                    let difference = Int(time - currentDate.timeIntervalSince1970)
                    if (difference > 0) {
                        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
                        
                        let timeDifference = (time - currentDate.timeIntervalSince1970)
                        basicAnimation.fromValue = (timerTime - timeDifference) / timerTime
                        basicAnimation.toValue = 1
                        basicAnimation.duration = timeDifference
                        
                        basicAnimation.fillMode = kCAFillModeForwards
                        basicAnimation.setValue(table.id, forKey: "id")
                        basicAnimation.delegate = self
                        
                        viewWithTag.shapeLayer.add(basicAnimation, forKey: "urSoBasic")
                    } else {
                        viewWithTag.table.backgroundColor = Table().getColor(status: -1)
                        viewWithTag.order.backgroundColor = Table().getColor(status: -1)
                    }
                }
            }
        }
    }
    
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let tableId: Int = anim.value(forKey: "id") as? Int {
            for table in self.tables {
                if table.id == tableId {
                    if let viewTable: NewTableView = scrollView.viewWithTag(-table.workspace)?.viewWithTag(table.id + 100) as? NewTableView {
                        let currentDate = Date()
                        for order in table.orders {
                            if order.time < currentDate.timeIntervalSince1970 {
                                viewTable.table.backgroundColor = Table().getColor(status: -1)
                                viewTable.order.backgroundColor = Table().getColor(status: -1)
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
    }
    
    
    // Проверка статуза заказа для вывода дополнительного меню
    func checkTimerOrder(tableRow: Int, orderRow: Int) {
        if (self.tables[tableRow].orders[orderRow].status == 2) {
            let text = "В данный момент вы принесли заказ клиенту. Клиент:"
            showAlertFive(text: text, tableRow: tableRow, orderRow: orderRow, typeWork: -1)
        } else if (self.tables[tableRow].orders[orderRow].status >= 2 + self.settings.countIterations) {
            let text = "Вы подходили к клиенту уже " + String(self.settings.countIterations) + " или более раз(а). Клиент:"
            showAlertFive(text: text, tableRow: tableRow, orderRow: orderRow, typeWork: -1)
        } else {
            // Обновление статуса заказа
            self.updateOrder(tableRow: tableRow, orderRow: orderRow, status: self.tables[tableRow].orders[orderRow].status + 1)
        }
    }
    
    
    func showAlertFive(text: String, tableRow: Int, orderRow: Int, typeWork: Int) {
        if let viewAlertFive = Bundle.main.loadNibNamed("AlertFive", owner: self, options: nil)?.first as? AlertFive {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAlertFive.frame = rect
            viewAlertFive.orderRow = orderRow
            viewAlertFive.tableRow = tableRow
            viewAlertFive.labelInfo.text = text
            viewAlertFive.delegate = self
            if typeWork > 0 {
                viewAlertFive.typeWork = typeWork
                viewAlertFive.btnOne.setTitle("Перенести",for: .normal)
                viewAlertFive.btnTwo.setTitle("Другой столик",for: .normal)
                viewAlertFive.btnThree.setTitle("Отмена",for: .normal)
            }
            view.addSubview(viewAlertFive)
        }
    }
    
    
    // MARK: Работа с уведомлениями
    
    // Очистка данных по выделенному столу
    func clearSelectedTable () {
        self.isChangeTable = false
        self.oldTableRow = -1
    }
    
    // Удаление уведомления
    func deleteAllNotifications () {
        let center = UNUserNotificationCenter.current()
        let localOrders = self.coreDataParser.getOrders(cafe: self.user.cafe)
        for order in localOrders {
            center.removePendingNotificationRequests(withIdentifiers: [String(order.timeId)])
        }
    }
    
    func addAllNotifications () {
        let center = UNUserNotificationCenter.current()
        let localOrders = self.coreDataParser.getOrders(cafe: self.user.cafe)
        for order in localOrders {
            if order.needUpdate != 2 {
                let content = UNMutableNotificationContent()
                for table in self.tables {
                    if table.id == order.idTable {
                        content.title = "\"" + table.name + "\""// Заказ № " + String(order.cafeNumber)
                        content.body = ""
                        content.sound = UNNotificationSound.default()
                        
                        let calendar = Calendar(identifier: .gregorian)
                        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: order.time))
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        let request = UNNotificationRequest(identifier: String(order.timeId), content: content, trigger: trigger)
                        center.add(request, withCompletionHandler: nil)
                        break
                    }
                }
            }
        }
    }
    
    func deleteNotification (order: Order) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(order.timeId)])
    }
    
    func addNotification (order: Order) {
        let center = UNUserNotificationCenter.current()
        if order.needUpdate != 2 {
            let content = UNMutableNotificationContent()
            for table in self.tables {
                if table.id == order.idTable {
//                    content.title = "Нужно вернуться к " + table.name + " Заказ № " + String(order.cafeNumber)
                    content.title = "\"" + table.name + "\""// Заказ № " + String(order.cafeNumber)
                    content.body = ""
                    content.sound = UNNotificationSound.default()
                    
                    let calendar = Calendar(identifier: .gregorian)
                    let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: Date(timeIntervalSince1970: order.time))
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: String(order.timeId), content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: nil)
                    break
                }
            }
        }
    }
    
    
    func deleteLocalNotification (tableRow: Int, orderRow: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [String(self.tables[tableRow].orders[orderRow].timeId)])
    }
    
    
    // Создание уведомления
    func createLocalNotification (tableRow: Int, orderRow: Int, date: Date) {
        let content = UNMutableNotificationContent()
//        content.title = "Нужно вернуться к " + self.tables[tableRow].name
            content.title = "\"" + self.tables[tableRow].name + "\""
        // Заказ № " + String(order.cafeNumber)
//            + " Заказ № " + String(self.tables[tableRow].orders[orderRow].cafeNumber)
        content.body = ""
        content.sound = UNNotificationSound.default()
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: String(self.tables[tableRow].orders[orderRow].timeId), content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
    
    
    // MARK: Работа с таймером
    
    // Аналог onPause
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        timerUpload.invalidate()
        timerSettings.invalidate()
    }
    
    
    // Аналог onResume
    override func viewDidAppear(_ animated: Bool) {
        runTimer()
    }
    
    
    // Запуск таймера на обновление рабочей области
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 20, target: self,   selector: (#selector(VCPWorkDesign.checkDelays)), userInfo: nil, repeats: true)
        timerUpload = Timer.scheduledTimer(timeInterval: 30, target: self,   selector: (#selector(VCPWorkDesign.uploadData)), userInfo: nil, repeats: true)
        timerSettings = Timer.scheduledTimer(timeInterval: 80, target: self,   selector: (#selector(VCPWorkDesign.refreshSettings)), userInfo: nil, repeats: true)
    }
    
    
    @objc func checkDelays() {
        print("checkDelays Запустилось")
        let currentDate = Date()
        var tableRow = 0
        for table in self.tables {
            var status = 0
            var timeOfEnd = 0.0
            var currentOrder = -1
            var i = 0
            for order in table.orders {
                if (timeOfEnd == 0) {
                    timeOfEnd = order.time
                    status = order.status
                    currentOrder = i
                } else if (order.time < timeOfEnd) {
                    timeOfEnd = order.time
                    status = order.status
                    currentOrder = i
                }
                i += 1
            }
            if (status > 0) {
                var difference = Int(timeOfEnd - currentDate.timeIntervalSince1970)
                if (difference < 0) {
                    difference = -difference
                    let minutes = Int(difference / 60)
                    let seconds = difference % 60
                    
                    if (table.orders[currentOrder].delay_flag == 0) {
                        if (minutes >= self.settings.maxDelay && seconds > 0) {
                            self.addDelay(tableRow: tableRow, orderRow: currentOrder)
                        }
                    }
                }
                
            }
            tableRow += 1
        }
    }
    
    
    @objc func refreshSettings() {
        getSettings(needTables: false)
    }
    
    
    @objc func uploadData() {
        print ("Попытка залить данные на сервер")
        let localOrders = coreDataParser.getOrders(cafe: self.user.cafe)
        for order in localOrders {
            if (order.needUpdate > 0) {
                if (order.needUpdate == 1) {
                    uploadUpdateOrder(order: order)
                } else if (order.needUpdate == 2) {
                    uploadDeleteOrder(order: order)
                }
            }
        }
        let localDelays = coreDataParser.getDelays()
        for delay in localDelays {
            uploadAddDelay(delay: delay)
        }
    }
    
    
    func uploadUpdateOrder(order: Order) {
        if (Connectivity.isConnectedToInternet) {
            var parameters = [String: String]()
            if (order.id < 0) {
                print ("uploadUpdateOrder")
                parameters["delay_flag"] = String(order.delay_flag)
                parameters["date"] = String(order.time)
                parameters["api_token"] = self.user.token
                parameters["table"] = String(order.idTable)
                parameters["waiter"] = String(self.user.id)
                parameters["status"] = String(order.status)
                parameters["cafe"] = String(self.user.cafe)
                parameters["number"] = String(order.cafeNumber)
                
                request(urlString.getUrl() + "api/AddOrder", method: .post, parameters: parameters).responseJSON {
                    response in
                    let response = self.jsonParser.parseAdd(JSONData: response.data!)
                    if (response.isError) {
                        self.showAlertView(error: response.text)
                    } else {
                        order.id = response.id
                        order.needUpdate = 0
                        self.coreDataParser.updateOrder(order: order)
                        
                        for table in self.tables {
                            if (table.id == order.idTable) {
                                var i = 0
                                while i < table.orders.count {
                                    if (table.orders[i].timeId == order.timeId) {
                                        table.orders[i].id = order.id
                                        table.orders[i].needUpdate = 0
                                        break
                                    }
                                    i+=1
                                }
                                break
                            }
                        }
                    }
                }
            } else {
                print ("updateOrder")
                parameters["api_token"] = self.user.token
                parameters["cafe"] = String(self.user.cafe)
                parameters["waiter"] = String(self.user.id)
                parameters["table"] = String(order.idTable)
                parameters["date"] = String(order.time)
                parameters["status"] = String(order.status)
                parameters["number"] = String(order.cafeNumber)
                parameters["order"] = String(order.id)
                parameters["delay_flag"] = String(order.delay_flag)
                request(urlString.getUrl() + "api/UpdateOrder", method: .post, parameters: parameters).responseJSON {
                    response in
                    let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                    if (response.isError) {
                        //                        self.showEmptyFieldAlert(error: response.text)
                    } else {
                        order.needUpdate = 0
                        self.coreDataParser.updateOrder(order: order)
                    }
                }
            }
        }
    }
    
    
    func uploadDeleteOrder(order: Order) {
        if (order.id < 0) {
            self.coreDataParser.deleteOrderByTimeId(order: order)
        } else {
            if (Connectivity.isConnectedToInternet) {
                print ("deleteOrder")
                var parameters = [String: String]()
                parameters["api_token"] = self.user.token
                parameters["cafe"] = String(self.user.cafe)
                parameters["order"] = String(order.id)
                request(urlString.getUrl() + "api/DeleteOrder", method: .post, parameters: parameters).responseJSON {
                    response in
                    let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                    if (response.isError) {
                        //                        self.showEmptyFieldAlert(error: response.text)
                    } else {
                        self.coreDataParser.deleteOrderByTimeId(order: order)
                    }
                }
            }
        }
    }
    
    
    func uploadAddDelay(delay: Delay) {
        if (Connectivity.isConnectedToInternet) {
            print ("addDelay")
            
            var parameters = [String: String]()
            parameters["api_token"] = self.user.token
            parameters["cafe"] = String(delay.cafe)
            parameters["waiter"] = String(delay.waiter)
            parameters["date"] = String(delay.date)
            
            request(urlString.getUrl() + "api/AddDelay", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseAdd(JSONData: response.data!)
                if (response.isError) {
                    print ("Добавление косяка неудачно")
                } else {
                    print ("Добавление косяка успешно")
                    self.coreDataParser.deleteDelay(delay: delay)
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
