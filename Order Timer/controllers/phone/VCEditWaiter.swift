//
//  VCEditWaiter.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 16.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class VCEditWaiter: UIViewController {

    @IBOutlet weak var btnEdit: UIBarButtonItem!
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
   
    var isEdit = false
    var waiter = Waiter()
    
    
    override func viewWillAppear(_ animated: Bool) {
        if (isEdit) {
            btnEdit.title = "Изменить"
            textFieldName.text = waiter.name
            textFieldPhone.text = waiter.phone
            textFieldLogin.text = waiter.login
        } else {
            btnEdit.title = "Добавить"
        }
        GlobalConstants.currentViewController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
//            topConstraint.constant = 20
//        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    
    @IBAction func btnEditClicked(_ sender: Any) {
        view.endEditing(true)
        let waiterValues = checkWaiterData()
        if (waiterValues.count == 4) {
            if (isEdit) {
                self.prepareEditWaiter(id: self.waiter.id, waiterValues: waiterValues)
            } else {
                self.prepareAddWaiter(waiterValues: waiterValues)
            }
        } else {
            showEmptyFieldAlert(error: "Для добавления нового официанта не заполнены все поля")
        }
    }
    
    // MARK: Работа с базой данных
    
    func prepareAddWaiter(waiterValues: [String]) {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["name"] = waiterValues[0]
            parameters["phone"] = waiterValues[1]
            parameters["login"] = waiterValues[2]
            parameters["password"] = waiterValues[3]
            GlobalConstants.alamofireResponse.addWaiter(parameters: parameters, delegate: self)
  
//            request(urlString.getUrl() + "api/AddWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseAdd(JSONData: response.data!)
//                if (response.isError) {
//                    self.showEmptyFieldAlert(error: response.text)
//                } else {
//                   self.showEditCompleteAlert(msg: "Добавление произведено успешно")
//                }
//            }
        }
    }
    
    
    func prepareEditWaiter(id: Int, waiterValues: [String]) {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["user"] = id
            parameters["name"] = waiterValues[0]
            parameters["phone"] = waiterValues[1]
            parameters["login"] = waiterValues[2]
            parameters["password"] = waiterValues[3]
            
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe),
//                              "user":String(id),
//                              "name":  waiterValues[0],
//                              "phone":  waiterValues[1],
//                              "login":  waiterValues[2],
//                              "password":  waiterValues[3]]
            
//            request(urlString.getUrl() + "api/UpdateWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                    self.showEmptyFieldAlert(error: response.text)
//                } else {
//                    self.showEditCompleteAlert(msg: "Изменение произведено успешно")
//                }
//            }
        }
    }
    
    
    func checkWaiterData() -> [String] {
        var waiterValues = [String]()
        let name = textFieldName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = textFieldPhone.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let login = textFieldLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (name.count > 0) {
            waiterValues.append(name)
        }
        if (phone.count > 0) {
            waiterValues.append(phone)
        }
        if (login.count > 0) {
            waiterValues.append(login)
        }
        if (pass.count > 0) {
            waiterValues.append(pass)
        }
        return waiterValues
    }
    
    
    // MARK: Алерты
    
    func showEmptyFieldAlert(error: String) {
        let alert = UIAlertController(title: "Внимание", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showEditCompleteAlert(msg: String) {
        let alert = UIAlertController(title: "Внимание", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ОК", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
           self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension VCEditWaiter: BackEndWaitersProtocol {
    func returnAddSuccess() {
        self.showEditCompleteAlert(msg: "Добавление произведено успешно")
    }
    
    func returnUpdateSuccess() {}
    
    func returnChangeSuccess() {}
    
    func returnDeleteSuccess() {}
    
    
    func returnError(error: String) {
        self.showEditCompleteAlert(msg: error)
    }
    
    func returnMy(waiters: [Waiter]) {}
    
    
}






