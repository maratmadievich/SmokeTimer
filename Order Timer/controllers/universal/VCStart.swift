//
//  VCStart.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 05.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

protocol AddWaiterProtocol {
    func addWaiter(waiter: Waiter)
}

protocol ReloadWaitersProtocol {
    func reloadWaiters()
}

protocol ChangeWorkspaceProtocol {
    func cafeEditorShowAlert(error: String)
    func cafeEditorChangeWorkspaceCount(settings: Settings) 
}

protocol NowProtocol {
    func nowCloseWork()
    func nowShowAlert(error: String)
}

protocol CafeEditorProtocol {
    func showAddTableAlert(minTableSize: Double, width: Double, height: Double)
}

protocol AlertAddTableProtocol {
    func addAlertTable(type: Int, name: String, size: CGFloat)
}



class VCStart: UIViewController, AddWaiterProtocol, ReloadWaitersProtocol, ChangeWorkspaceProtocol, NowProtocol, AlertExitProtocol, CafeEditorProtocol, AlertAddTableProtocol {

    @IBOutlet weak var viewWork: UIView!
    @IBOutlet weak var viewSupport: UIView!
    
    let urlString = UrlString()
    
    var selectedOption = -1
    
    var user = User()
    var viewNow = NowView()
    var viewSettings = SettingsView()
    var viewCafeEditor = CafeEditor()
    
    var tableSize:CGFloat = 0
    var minDistance:CGFloat = 0
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = user.cafeName + " - Администратор"
//        self.title = "Администратор"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableSize = (self.view.frame.size.width * 2) / 30
        minDistance = (self.view.frame.size.width * 2) / 300
        print ("width \(self.view.frame.size.width)")
        print ("height \(self.view.frame.size.height)")
    }
    
    
    @IBAction func btnSettingsClicked(_ sender: Any) {
        if (selectedOption != 1) {
            selectedOption = 1
            clearWorkspace()
            
            if let viewTable = Bundle.main.loadNibNamed("Settings", owner: self, options: nil)?.first as? SettingsView {
                viewSettings = viewTable
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWork.frame.size.width, height: viewWork.frame.size.height))
                viewSettings.frame = rect
                viewSettings.delegate = self
                viewWork.addSubview(viewSettings)
            }
        }
    }
    
    
    @IBAction func btnStatisticClicked(_ sender: Any) {
        if (selectedOption != 2) {
            selectedOption = 2
            clearWorkspace()
            
            if let viewStatistic = Bundle.main.loadNibNamed("Statistic", owner: self, options: nil)?.first as? StatisticView {
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWork.frame.size.width, height: viewWork.frame.size.height))
                viewStatistic.user = self.user
                viewStatistic.frame = rect
                viewWork.addSubview(viewStatistic)
            }
        }
    }
    
    
    @IBAction func btnRealTimeClicked(_ sender: Any) {
        if (selectedOption != 3) {
            selectedOption = 3
            clearWorkspace()
            
            if let viewWaiters = Bundle.main.loadNibNamed("WaiterList", owner: self, options: nil)?.first as? WaiterList {
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewSupport.frame.size.width, height: viewSupport.frame.size.height))
                viewWaiters.frame = rect
                viewWaiters.delegate = self
                viewWaiters.user = self.user
                viewSupport.addSubview(viewWaiters)
            }
            
            if let view = Bundle.main.loadNibNamed("Now", owner: self, options: nil)?.first as? NowView {
                viewNow = view
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWork.frame.size.width, height: viewWork.frame.size.height))
                viewNow.user = self.user
                viewNow.frame = rect
                
                viewNow.tableWidth = tableSize
                viewNow.tableHeight = tableSize
                viewNow.minDistance = minDistance
                
                viewWork.addSubview(viewNow)
            }
        }
    }
    
    
    @IBAction func btnCafeEditorClicked(_ sender: Any) {
        if (selectedOption != 4) {
            selectedOption = 4
            clearWorkspace()
            
            if let viewAddWorkspace = Bundle.main.loadNibNamed("AddWorkspace", owner: self, options: nil)?.first as? AddWorkspace {
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewSupport.frame.size.width, height: viewSupport.frame.size.height))
                viewAddWorkspace.frame = rect
                viewAddWorkspace.delegate = self
                viewAddWorkspace.user = self.user
                
                viewSupport.addSubview(viewAddWorkspace)
            }
            
            if let viewEditor = Bundle.main.loadNibNamed("CafeEditor", owner: self, options: nil)?.first as? CafeEditor {
                viewCafeEditor = viewEditor
                let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: viewWork.frame.size.width, height: viewWork.frame.size.height))
                viewCafeEditor.user = self.user
                viewCafeEditor.frame = rect
                viewCafeEditor.delegate = self
                viewCafeEditor.tableWidth = tableSize
                viewCafeEditor.tableHeight = tableSize
                viewCafeEditor.minDistance = minDistance
                
                viewWork.addSubview(viewCafeEditor)
            }
        }
    }
    
    
    @IBAction func btnExitCLicked(_ sender: Any) {
        if let viewAlertExit = Bundle.main.loadNibNamed("AlertExit", owner: self, options: nil)?.first as? AlertExit {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAlertExit.frame = rect
            viewAlertExit.delegate = self
            view.addSubview(viewAlertExit)
        }
    }
    
    
    func addWaiter(waiter: Waiter) {
        if let viewAddWaiter = Bundle.main.loadNibNamed("AddWaiter", owner: self, options: nil)?.first as? AddWaiter {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAddWaiter.user = self.user
            viewAddWaiter.waiter = waiter
            viewAddWaiter.frame = rect
            viewAddWaiter.delegate = self
            view.addSubview(viewAddWaiter)
        }
    }
    
    
    func reloadWaiters() {
        viewSettings.prepareGetWaiters()
    }
    
    
    func clearWorkspace() {
        for view in self.viewWork.subviews {
            view.removeFromSuperview()
        }
        for view in self.viewSupport.subviews {
            view.removeFromSuperview()
        }
    }
    
    
    func cafeEditorShowAlert(error: String) {
        viewCafeEditor.showAlertView(error: error)
    }
    
    
    func cafeEditorChangeWorkspaceCount(settings: Settings) {
        viewCafeEditor.setWorkspace(setting: settings)
    }
    
    
    func nowShowAlert(error: String) {
        viewNow.showAlertView(error: error)
    }
    
    
    func nowCloseWork() {
        viewNow.clearOrders()
    }
    
    
    func responseExit(response: Int) {
        if (response > 0) {
            _ = navigationController?.popViewController(animated: true)
        }
    }

    
    func showAddTableAlert(minTableSize: Double, width: Double, height: Double) {
        if let viewAddTable = Bundle.main.loadNibNamed("AlertAddTable", owner: self, options: nil)?.first as? AlertAddTable {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAddTable.frame = rect
            
            viewAddTable.spaceWidth = width
            viewAddTable.spaceHeight = height
            viewAddTable.minTableSIze = minTableSize
            
            viewAddTable.delegate = self
            view.addSubview(viewAddTable)
        }
    }
    
    
    func addAlertTable(type: Int, name: String, size: CGFloat) {
        viewCafeEditor.tableType = type
        viewCafeEditor.tableName = name
        viewCafeEditor.tableSize = size
        viewCafeEditor.changeBtnAddTableValue()
    }
    

}
