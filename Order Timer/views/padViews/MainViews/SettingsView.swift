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
    func prepareGetWaiters()
    func showAlertView(error: String)
}

class SettingsView: UIView, SettingsProtocol {

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
    
    var selectedIndexPath: IndexPath?
    
    var waiters = [Waiter]()
    
    
    override func layoutSubviews() {
        
    }
    
    func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.addGestureRecognizer(tap)
        GlobalConstants.alamofireResponse.getWaiters(delegate: self)
        GlobalConstants.alamofireResponse.getSettings(delegate: self)
    }
    
    
    @IBAction func btnAddClicked(_ sender: Any) {
        delegate?.addWaiter(waiter: Waiter())
    }
    
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        self.endEditing(true)
        checkTimerData()
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
            prepareSaveSettings()
        }
    }
    
    
    func prepareGetWaiters() {
        GlobalConstants.alamofireResponse.getWaiters(delegate: self)
    }
    
    func prepareSaveSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["order_timer"] = textFieldStartOrder.text!
            parameters["minutes_timer"] = textFieldFiveMinutes.text!
            parameters["work_timer"] = textFieldWorkTimer.text!
            parameters["timer_count"] = textFieldCountIterations.text!
            parameters["max_order"] = textFieldOrderCount.text!
            parameters["max_delay"] = textFieldDelay.text!
            GlobalConstants.alamofireResponse.saveSettings(parameters: parameters, delegate: self)
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

extension SettingsView: UITableViewDelegate {}

extension SettingsView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.waiters.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == waiters.count {
            let cell = Bundle.main.loadNibNamed("RowAddWaiter", owner: self, options: nil)?.first as! TVCAddWaiter
            cell.backgroundColor = UIColor.clear
            cell.delegateAddWaiter = delegate
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("RowWaiterDesign", owner: self, options: nil)?.first as! TVCWaiterDesign
            cell.backgroundColor = UIColor.clear
            cell.delegateSettings = self
            cell.waiter = waiters[indexPath.row]
            cell.delegateAddWaiter = delegate
            cell.labelName.text = waiters[indexPath.row].name
            return cell
        }
    }
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
}

extension SettingsView: UITextFieldDelegate {
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
}

extension SettingsView: BackEndSettingsProtocol {
    
    func returnError(error: String) {
        self.showAlertView(error: error)
    }
    
    func returnSettingsSuccess() {
        self.setSettings()
    }
    
    func returnUpdateSuccess() {
        self.showAlertView(error: "Изменение прошло успешно")
    }
    
}

extension SettingsView: BackEndWaitersProtocol {
    
    func returnMy(waiters: [Waiter]) {
        self.waiters = waiters
        tableView.reloadData()
    }
    
    func returnAddSuccess() {}
    
    func returnChangeSuccess() {}
    func returnDeleteSuccess() {}
}







