//
//  AddWaiter.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 10.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class AddWaiter: UIView, UITextFieldDelegate {
    var delegate: ReloadWaitersProtocol?
    
    @IBOutlet weak var labelWaiter: UILabel!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var viewAlert: UIView!
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAdd: UIButton!

    var waiter = Waiter()
    
    
    
    override func layoutSubviews() {
        editTextFields()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    
    func editTextFields() {
        
//        textFieldName.attributedPlaceholder = NSAttributedString(string: "Имя", attributes:[kCTForegroundColorAttributeName: UIColor.gray])
////        textFieldPhone.attributedPlaceholder = NSAttributedString(string: "Телефон", attributes:[NSForegroundColorAttributeName: UIColor.gray])
//        textFieldLogin.attributedPlaceholder = NSAttributedString(string: "Логин", attributes:[kCTForegroundColorAttributeName: UIColor.gray])
//        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes:[kCTForegroundColorAttributeName: UIColor.gray])
        if (waiter.id > 0) {
            textFieldName.text = waiter.name
//            textFieldPhone.text = waiter.phone
            textFieldLogin.text = waiter.login
            labelWaiter.text = "Редактирование официанта"
            btnAdd.setTitle("Изменить",for: .normal)
            
        }
    }
    
    
    @IBAction func btnSaveClicked(_ sender: Any) {
       let waiterValues = checkWaiterData()
        if (waiterValues.count == 3) {
            if waiter.id > 0 {
                editWaiter(id: waiter.id, waiterValues: waiterValues)
            } else {
                 prepareAddWaiter(waiterValues: waiterValues)
            }
        } else {
            showAlertView(error: "Для добавления нового официанта не заполнены все поля")
        }
    }
    
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    func checkWaiterData() -> [String] {
        var waiterValues = [String]()
        let name = textFieldName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        let phone = textFieldPhone.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let login = textFieldLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = textFieldPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (name.count > 0) {
            waiterValues.append(name)
        }
//        if (phone.count > 0) {
//            waiterValues.append(phone)
//        }
        if (login.count > 0) {
            waiterValues.append(login)
        }
        if (pass.count > 0) {
            waiterValues.append(pass)
        }
        return waiterValues
    }
    
    
    
    func prepareAddWaiter(waiterValues: [String]) {
        if (!Connectivity.isConnectedToInternet) {
            self.showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["name"] = waiterValues[0]
            parameters["login"] = waiterValues[1]
            parameters["password"] = waiterValues[2]
            GlobalConstants.alamofireResponse.addWaiter(parameters: parameters, delegate: self)
            
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe),
//                              "name":  waiterValues[0],
////                              "phone":  waiterValues[1],
//                              "login":  waiterValues[1],
//                              "password":  waiterValues[2]]
//            request(urlString.getUrl() + "api/AddWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseAdd(JSONData: response.data!)
//                if (response.isError) {
//                    self.showAlertView(error: response.text)
//                } else {
//                    let waiter = Waiter()
//                    waiter.id = response.id
//                    waiter.name = waiterValues[0]
////                    waiter.phone = waiterValues[1]
//                    waiter.login = waiterValues[1]
//                    waiter.password = waiterValues[2]
//                    self.delegate?.reloadWaiters()
//                    self.removeFromSuperview()
//
//                }
//            }
        }
    }
    
    
    func editWaiter(id: Int, waiterValues: [String]) {
        if (!Connectivity.isConnectedToInternet) {
            self.showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["user"] = id
            parameters["name"] = waiterValues[0]
            parameters["login"] = waiterValues[1]
            parameters["password"] = waiterValues[2]
            GlobalConstants.alamofireResponse.updateWaiter(parameters: parameters, delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe":String(self.user.cafe),
//                              "user":String(id),
//                              "name":  waiterValues[0],
////                              "phone":  waiterValues[1],
//                              "login":  waiterValues[1],
//                              "password":  waiterValues[2]]
//            request(urlString.getUrl() + "api/UpdateWaiter", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                    self.showAlertView(error: response.text)
//                } else {
//                    self.delegate?.reloadWaiters()
//                    self.removeFromSuperview()
//                }
//            }
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

extension AddWaiter: BackEndWaitersProtocol {
    
    func returnAddSuccess() {
        showAlertView(error: "Добавление произведено успешно")
        self.delegate?.reloadWaiters()
        self.removeFromSuperview()
    }
    
    func returnUpdateSuccess() {
        showAlertView(error: "Изменение произведено успешно")
        self.delegate?.reloadWaiters()
        self.removeFromSuperview()
    }
    
    
    func returnChangeSuccess() {}
    
    func returnDeleteSuccess() {}
    
    func returnError(error: String) {
        showAlertView(error: error)
    }
    
    func returnMy(waiters: [Waiter]) {}
    
    
}




