//
//  CafeEditor.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 10.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class CafeEditor: UIView, UIScrollViewDelegate {
    
    var delegate: CafeEditorProtocol?
    
    @IBOutlet weak var textFieldX: UITextField!
    @IBOutlet weak var textFieldY: UITextField!
    @IBOutlet weak var textFieldTableName: UITextField!
    @IBOutlet weak var textFieldWorkspace: UITextField!
    
    @IBOutlet weak var btnAddTable: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    
    let urlString = UrlString()
    private let jsonParser = JsonParser()
    
    var user = User()
    var settings = Settings()
    
    private var selectedRow = 0
    var pageCount: CGFloat = 1
  
    var tableWidth: CGFloat = 0
    var tableHeight: CGFloat = 0
    var minDistance: CGFloat = 0
    
    private var isAddTable = false
    private var tryAddindTable = false
    
    private var tables = [Table]()
    
    var tableName = ""
    var tableType = -1
    var tableSize: CGFloat = 0
    

//    override func awakeFromNib() {
//        //        setTableSize()
//        getTables()
//    }
    override func layoutSubviews() {
//        deleteTable(id: 11)
        self.getTables()
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
    
    private func loadScrollView() {
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
    
   
    // MARK: Обработка нажатий
    
    @IBAction func btnAddTableClicked(_ sender: Any) {
        if (!isAddTable) {
            delegate?.showAddTableAlert(minTableSize: Double(tableHeight), width: Double(scrollView.frame.size.width), height: Double(scrollView.frame.size.height))
        } else {
            changeBtnAddTableValue()
        }
        
//        self.endEditing(true)
//        if (textFieldX.text!.count > 0 && textFieldY.text!.count > 0) {
//            let x = Double(textFieldX.text!)!
//            let y = Double(textFieldY.text!)!
//            if (x > 0 && y > 0) {
//                let workspace = pageControl.currentPage + 1
//                if checkMaxTableInWorkspace(workspace: workspace) {
//                    checkPossibilityAddTable(workspace: workspace, width: (scrollView.viewWithTag(-workspace)?.frame.size.width)!, height: scrollView.frame.size.height, x: CGFloat(x), y: CGFloat(y))
//                } else {
//                    showAlertView(error: "В одной комнате может располагаться не более 15 столов")
//                }
//            } else {
//                changeBtnAddTableValue()
//            }
//        } else {
//            changeBtnAddTableValue()
//        }
    }
    
    
    @objc func tapViewCafe(_ gestureReconizer: UITapGestureRecognizer) {
        print("View нажата!")
        if (!tryAddindTable) {
            for view in self.scrollView.subviews {
                if view.tag == gestureReconizer.view?.tag {
                    let tapPoint = gestureReconizer.location(in: view)
                    if (isAddTable) {
                        tryAddindTable = true
                        if checkMaxTableInWorkspace(workspace: -view.tag) {
                            checkPossibilityAddTable(workspace: -view.tag, width: view.frame.size.width, height: view.frame.size.height, x: tapPoint.x, y: tapPoint.y)
                        } else {
                            tryAddindTable = false
                            showAlertView(error: "В одной комнате может располагаться не более 15 столов")
                        }
                    } else {
                        print ("Не нажата кнопка \"Добавить столик\"")
                        checkTapToTable(workspace: pageControl.currentPage + 1, x: tapPoint.x, y: tapPoint.y)
                    }
                    break
                }
            }
        }
    }
    
    
    // MARK: Вспомогательные функции работы со столиками
    
    // Установка размеров столиков
    private func setTableSize() {
        var distanse = self.scrollView.frame.size.height
        if (distanse < self.scrollView.frame.size.width) { distanse = self.scrollView.frame.size.width}
        self.tableWidth = CGFloat(distanse / 20)
        self.tableHeight = CGFloat(distanse / 20)
        self.minDistance = CGFloat(distanse / 200)
    }
    
    
    // Проверка, какие столики нужно удалить
    // При редактировании количества комнат
    private func checkDeleteTables(workspaceCount: Int) {
        for table in self.tables {
            if table.workspace > workspaceCount {
                deleteTable(id: table.id)
            }
        }
    }
    
    
    // Проверка возможности добавления столика в указанное место
    private func checkPossibilityAddTable(workspace: Int, width: CGFloat, height: CGFloat, x: CGFloat, y: CGFloat) {
        print ("X = " + String(describing: x))
        print ("Y = " + String(describing: y))
        
        let newX1 = x - tableWidth
        var newX2 = x + tableWidth
        if (tableType == 2) {
            let size = -tableSize * scrollView.frame.size.width - tableWidth
            newX2 = x + size
        }
        let newY1 = y - tableHeight
        var newY2 = y + tableHeight
        if (tableType == 1) {
            let size = tableSize * scrollView.frame.size.height - tableWidth
            newY2 = y + size
        }
        
        if (newX1 >= minDistance && newX2 <= width - minDistance) {
            if (newY1 >= minDistance && newY2 <= height - minDistance) {
                if (checkHaveTable(workspace: workspace, x: x, y: y)) {
//                    var text = textFieldTableName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    var text = tableName
                    if (text == "") {
                        text = String(describing: tables.count + 1)
                    }
                    addTable(workspace: workspace, name: text, x: x, y: y, size: tableSize)
                    
                } else {
                    showAlertView(error: "На данной позиции есть столик.")
                    tryAddindTable = false
                }
            } else {
                print ("Проблема с Y")
                showAlertView(error: "Вы хотите разместить столик слишком близко к границе помещения")
                tryAddindTable = false
            }
        } else {
            print ("Проблема с X")
            showAlertView(error: "Вы хотите разместить столик слишком близко к границе помещения")
            tryAddindTable = false
        }
    }
    
    // Проверка наличия столика
    private func checkHaveTable(workspace: Int, x: CGFloat, y: CGFloat) -> Bool {
        var isFree = true
        var i = 0
        let newX1 = x - tableWidth
        var newX2 = x + tableWidth
        if (tableType == 2) {
            let size = -tableSize * scrollView.frame.size.width - tableWidth
            newX2 = x + size
        }
        let newY1 = y - tableHeight
        var newY2 = y + tableHeight
        if (tableType == 1) {
            let size = tableSize * scrollView.frame.size.height - tableWidth
            newY2 = y + size
        }
        while (i < tables.count) {
            if (tables[i].workspace == workspace) {
                let tableX = tables[i].x * self.scrollView.frame.size.width
                let tableY = tables[i].y * self.scrollView.frame.size.height
                
                var oldX1 = tableX - tableWidth
                var oldX2 = tableX + tableWidth
                if (tables[i].size < 0) {
                    let size = -tables[i].size * scrollView.frame.size.width - tableWidth
                    oldX2 = tableX + size
                }
                var oldY1 = tableY - tableHeight
                var oldY2 = tableY + tableHeight
                if (tables[i].size > 0) {
                    let size = tables[i].size * scrollView.frame.size.height - tableWidth
                    oldY2 = tableY + size
                }
                oldX1 -= minDistance
                oldX2 += minDistance
                oldY1 -= minDistance
                oldY2 += minDistance
                var byX = false
                var byY = false
                if (oldX1 <= newX1 && oldX2 >= newX1) {
                    byX = true
                } else if (oldX1 <= newX2 && oldX2 >= newX2) {
                    byX = true
                } else if (newX1 <= oldX1 && newX2 >= oldX1) {
                    byX = true
                }  else if (newX1 <= oldX2 && newX2 >= oldX2) {
                    byX = true
                }
                if (byX) {
                    if (oldY1 <= newY1 && oldY2 >= newY1) {
                        byY = true
                    } else if (oldY1 <= newY2 && oldY2 >= newY2) {
                        byY = true
                    } else if (newY1 <= oldY1 && newY2 >= oldY1) {
                        byY = true
                    }  else if (newY1 <= oldY2 && newY2 >= oldY2) {
                        byY = true
                    }
                }
                if (byX && byY) {
                    isFree = false
                    break
                }
            }
            i += 1
        }
        return isFree
    }
//    private func checkHaveTable(workspace: Int, x: CGFloat, y: CGFloat) -> Bool {
//        var isFree = true
//        var i = 0
//        var currentWidth = tableWidth * 2
//        var currentHeight = tableHeight * 2
//        if (tableType == 1) {
//            currentHeight = tableSize * scrollView.frame.size.height
//        } else if (tableType == 2) {
//            currentWidth = tableSize * scrollView.frame.size.width
//        }
//        while (i < tables.count) {
//            if (tables[i].workspace == workspace) {
//                var tableX = tables[i].x * self.scrollView.frame.size.width
//                var tableY = tables[i].y * self.scrollView.frame.size.height
//                var difX = tableX - x
//                if (difX < 0) { difX = -difX}
//                var difY = tableY - y
//                if (difY < 0) { difY = -difY}
//
//                if (difX <= currentWidth * 2 && difY <= currentHeight * 2) {
//                    isFree = false
//                    break
//                }
//            }
//            i += 1
//        }
//        return isFree
//    }
    
    // Проверка количества столиков в комнате
    private func checkMaxTableInWorkspace(workspace: Int) -> Bool {
        var countTableInWorkspace = 0
        for table in tables {
            if (table.workspace == workspace) {
                countTableInWorkspace += 1
            }
        }
        return countTableInWorkspace < 15
    }
    
    // Проверка, нажато ли на столик
    private func checkTapToTable(workspace: Int, x: CGFloat, y: CGFloat) {
        var detectTable = false
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
                if (oldX1 <= x && x <= oldX2) {
                    if (oldY1 <= y && y <= oldY2) {
                        self.selectedRow = i
                        detectTable = true
                        self.showDeleteTableAlert()
                        break
                    } else {
                        print ("Не столик по Y")
                    }
                } else {
                    print ("Не столик по X")
                }
            }
            i += 1
        }
        if (!detectTable) {
//            showAlertView(error: "X: " + String(describing: x) + ", Y: " + String(describing: y))
//            ToastCenter.default.cancelAll()
//            toast = Toast(text: "X: " + String(describing: x) + ", Y: " + String(describing: y), delay: 0.5, duration: 1.0)
//            toast.show()
        }
    }
    
    // Отрисовка столика
    private func drawTable(table: Table) {
        var viewTable = Bundle.main.loadNibNamed("TableLong", owner: self, options: nil)?.first as! NewTableView
        if (table.size == 0) {
            viewTable = Bundle.main.loadNibNamed("NewTable", owner: self, options: nil)?.first as! NewTableView
        }
//        if let viewTable = Bundle.main.loadNibNamed("NewTable", owner: self, options: nil)?.first as? NewTableView {
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
            
            scrollView.viewWithTag(-table.workspace)?.addSubview(viewTable)
//        }
    }
    
    // Смена надписи на кнопке
    func changeBtnAddTableValue() {
        if (isAddTable) {
            btnAddTable.setTitle("+ Создать столик", for: .normal)
            self.tryAddindTable = false
        } else {
            btnAddTable.setTitle("Отмена", for: .normal)
        }
        isAddTable = !isAddTable
    }
    
    
    // MARK: Алерты
    
    private func showDeleteTableAlert() {
            self.deleteTable(id: self.tables[self.selectedRow].id)
    }
    
    
    // MARK: Работа с базой данных
    
    private func getTables() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe":String(self.user.cafe)]
            request(urlString.getUrl() + "api/CafeTable", method: .post, parameters: parameters).responseJSON {
                response in
                self.tables = self.jsonParser.parseTables(JSONData: response.data!, cafe: self.user.cafe)
            }
        }
    }
    
    
    private func addTable(workspace: Int, name: String, x: CGFloat, y: CGFloat, size: CGFloat) {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            
            let tableX = x / self.scrollView.frame.size.width
            let tableY = y / self.scrollView.frame.size.height
            
            let parameters = ["api_token":  self.user.token,
                              "cafe": String(self.user.cafe),
                              "name": name,
                              "size": String(describing: size),
                              "place_x": String(describing: tableX),
                              "place_y": String(describing: tableY),
                              "workspace": String(describing: workspace)]
            request(urlString.getUrl() + "api/AddTable", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseAdd(JSONData: response.data!)
                if (response.isError) {
                    self.showAlertView(error: response.text)
                } else {
                    let table = Table()
                    table.id = response.id
                    table.name = name
                    table.x = tableX
                    table.y = tableY
                    table.size = size
                    table.workspace = workspace
                    self.tables.append(table)
                    self.drawTable(table: table)
//                    self.textFieldX.text = ""
//                    self.textFieldY.text = ""
                    self.isAddTable = true
                    table.size = self.tableSize
                    self.changeBtnAddTableValue()
                    self.tryAddindTable = false
                }
            }
        }
    }
    
    
    private func deleteTable(id: Int) {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe":String(self.user.cafe),
                              "table":String(id)]
            request(urlString.getUrl() + "api/DeleteTable", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.showAlertView(error: response.text)
                } else {
                    var i = 0
                    while (i < self.tables.count) {
                        if (self.tables[i].id == id) {
                            if let viewWithTag = self.scrollView.viewWithTag(-self.tables[i].workspace)?.viewWithTag(id)  { //.viewCafe.viewWithTag(id) {
                                viewWithTag.removeFromSuperview()
                            } else {
                                print("Не получилось удалить столик!")
                            }
                            self.tables.remove(at: i)
                            break
                        }
                        i += 1
                    }
                }
            }
        }
    }
    
    
    func setWorkspace(setting: Settings) {
        settings = setting
        var minWorkspace = 1
        if (settings.workspaceCount > 1) {
            minWorkspace = settings.workspaceCount
        }
        for table in tables {
            if table.workspace > minWorkspace {
                deleteTable(id: table.id)
            }
        }
        self.loadScrollView()
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
    
    
}
