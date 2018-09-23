//
//  NowView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 13.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class NowView: UIView, UIScrollViewDelegate, CAAnimationDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var labelStatus: UILabel!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    var pageCount: CGFloat = 1
    
    var tableWidth: CGFloat = 0
    var tableHeight: CGFloat = 0
    var minDistance: CGFloat = 0
    
    var tables = [Table]()
    
    
    override func willMove(toSuperview newSuperview: UIView?) {
//        GlobalConstants.alamofireResponse.getSettings(delegate: self)
    }
    
    
    func loadData() {
        GlobalConstants.alamofireResponse.getSettings(delegate: self)
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
        
        var pageCount: CGFloat = CGFloat(GlobalConstants.settings.workspaceCount)
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
            self.scrollView.addSubview(workspace)
        }
        
        for table in self.tables {
            drawTable(table: table)
        }
    }
    
    
    // MARK: Вспомогательные функции работы со столиками
    
    // Установка размеров столиков
    func setTableSize() {
        var distanse = self.scrollView.frame.size.height
        if (distanse < self.scrollView.frame.size.width) { distanse = self.scrollView.frame.size.width}
        self.tableWidth = CGFloat(distanse / 20)
        self.tableHeight = CGFloat(distanse / 20)
        self.minDistance = CGFloat(distanse / 200)
    }
    
    
    // Отрисовка столика
    private func drawTable(table: Table) {
        var viewTable = Bundle.main.loadNibNamed("TableLong", owner: self, options: nil)?.first as! NewTableView
        if (table.size == 0) {
            viewTable = Bundle.main.loadNibNamed("NewTable", owner: self, options: nil)?.first as! NewTableView
        } else {
            viewTable.isTableLong = true
        }
        
        viewTable.tag = table.id
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
    
    
    // Смена статуса столиков
    func setStatus() {
        print("Статусы обновились")
        let currentDate = Date()
        for table in self.tables {
            if let viewWithTag: NewTableView = scrollView.viewWithTag(-table.workspace)?.viewWithTag(table.id) as? NewTableView {
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
                    timerTime = Double(GlobalConstants.settings.timeStartOrder) * 60.0
                    break
                    
                case 2:
                    timerTime = Double(GlobalConstants.settings.timeFiveMinutes) * 60.0
                    break
                    
                default:
                    timerTime = Double(GlobalConstants.settings.timeWorkTimer) * 60.0
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
                    if let viewTable: NewTableView = scrollView.viewWithTag(-table.workspace)?.viewWithTag(table.id) as? NewTableView {
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
    
    
    // MARK: Работа с базой данных
    
    func prepareGetTables() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getTables(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeTable", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.tables = self.jsonParser.parseTables(JSONData: response.data!, cafe: self.user.cafe)
//
//                self.loadScrollView()
//                self.getOrder()
//            }
        }
    }
    
    
    // Получение списка заказов
    func prepareGetOrders() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getOrders(delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeOrder", method: .post, parameters: parameters).responseJSON {
//                response in
//                let orders = self.jsonParser.parseOrder(JSONData: response.data!, cafe: self.user.cafe)
//
//                for order in orders {
//                    for table in self.tables {
//                        if order.idTable == table.id {
//                            table.orders.append(order)
//                            break
//                        }
//                    }
//                }
//                self.setStatus()
//            }
        }
    }
    
    
    func clearOrders() {
        GlobalConstants.settings.open = 0
        for table in tables {
            table.orders.removeAll()
        }
        self.setStatus()
        self.labelStatus.text = "Рабочая смена закрыта"
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
    
    
    func hiddenAlertView() {
        _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (timer) in
            UIView.transition(with: self.viewAlert, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.viewAlert.isHidden = true
            })
        }
    }

}

extension NowView: BackEndSettingsProtocol {
    
    func returnUpdateSuccess() {}
    
    func returnError(error: String) {
        self.showAlertView(error: error)
    }
    
    func returnSettingsSuccess() {
        if (GlobalConstants.settings.open > 0) {
            self.labelStatus.text = "Рабочая смена открыта"
        } else {
            self.labelStatus.text = "Рабочая смена закрыта"
        }
        self.prepareGetTables()
    }
}

extension NowView: BackEndTablesProtocol {
    
    func returnMy(tables: [Table]) {
        self.tables = tables
        self.loadScrollView()
        self.prepareGetOrders()
    }
    
    func returnAdd(table: Table) {}
    func returnDelete(table: Int) {}
    
}

extension NowView: BackEndOrdersProtocol {
    func returnMy(orders: [Order]) {
        for order in orders {
            for table in self.tables {
                if order.idTable == table.id {
                    table.orders.append(order)
                    break
                }
            }
        }
        self.setStatus()
    }
    
    func returnAdd(order: Order) {}
    func returnUpdate(order: Order) {}
    func returnDelete(order: Order) {}
    
    
}











