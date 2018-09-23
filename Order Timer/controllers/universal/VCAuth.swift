//
//  VCAuth.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 05.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class VCAuth: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    
    var textEmptyField = "Одно из полей не заполнено"
    
    var fromNet = false
    var isTryAuth = false
    
    let coreDataParser = CoreDataParser()
    
    
    override func viewWillAppear(_ animated: Bool) {
        textFieldLogin.text = coreDataParser.getUserLogin()
        GlobalConstants.currentViewController = self
        GlobalConstants.isHookNotPaid = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        textFieldLogin.attributedPlaceholder = NSAttributedString(string: "Логин", attributes:[kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray])
//        textFieldPassword.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes:[kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.gray])
        addImageToNavigationItem()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        view.addGestureRecognizer(tap)
    }
    
    
    func addImageToNavigationItem() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
        let image = UIImage(named: "icon2.png")//Cafe2.jpg
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
        // 5
//        if let iconView = Bundle.main.loadNibNamed("Icon", owner: self, options: nil)?.first as? IconView {
//            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 40, height: 40))
//            iconView.frame = rect
//            navigationItem.titleView = iconView
//        }
    }
    
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    

    @IBAction func btnAuthClicked(_ sender: Any) {
        if (!isTryAuth) {
            if (textFieldLogin.text!.count > 0
                && textFieldPassword.text!.count > 0) {
                tryAuth()
            } else {
                showAlertView(error: textEmptyField)
            }
        }
    }
    
    
    func tryAuth() {
        isTryAuth = true
        if (!Connectivity.isConnectedToInternet) {
            self.isTryAuth = false
            showAlertView(error: "Отсутствует соединение с Интернетом")
        } else {
            var parameters = Parameters()
            
            parameters["login"] = textFieldLogin.text!
            parameters["password"] = textFieldPassword.text!
            GlobalConstants.alamofireResponse.getToken(parameters: parameters, delegate: self)
            
//            request(urlString.getUrl() + "api/getToken", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.fromNet = true
//                self.user = self.jsonParser.parseUser(JSONData: response.data!)
//                if (self.user.id > 0) {
//                    self.user.login = self.textFieldLogin.text!
//                    self.user.pass = self.textFieldPassword.text!
////                    self.coreDataParser.deleteUser(id: self.user.id)
//                    self.coreDataParser.deleteUsers()
//                    self.coreDataParser.saveUser(user: self.user)
//                }
//                self.checkUser()
//                self.isTryAuth = false
//            }
        }
    }
    
    
    func checkUser() {
        isTryAuth = false
        self.textFieldPassword.text = ""
        if (GlobalConstants.user.id > 0) {
            if (GlobalConstants.user.paid != 1) {
                showAlertView(error: "Нужно оплатить работу приложения")
                view.endEditing(true)
                return
            }
            self.textFieldLogin.becomeFirstResponder()
            if (GlobalConstants.user.role == 1) {
                self.performSegue(withIdentifier: "showStart", sender: nil)
            } else {
                self.performSegue(withIdentifier: "showWork", sender: nil)
            }
        } else {
            showAlertView(error: GlobalConstants.user.error)
        }
        
        view.endEditing(true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showStart") {
        }
        if (segue.identifier == "showWork") {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                let vc = segue.destination as! VCPWorkDesign
            } else {
                let vc = segue.destination as! VCNowTable
                vc.fromAuth = true
            }
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""//Назад
        backItem.tintColor = UIColor.white
        navigationItem.backBarButtonItem = backItem
    }


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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

extension VCAuth: BackEndLoginProtocol {
    
    func returnLoginSuccess() {
        isTryAuth = false
        if (GlobalConstants.user.id > 0) {
            GlobalConstants.user.login = self.textFieldLogin.text!
            GlobalConstants.user.pass = self.textFieldPassword.text!
            
            self.coreDataParser.deleteUsers()
            self.coreDataParser.saveUser(user: GlobalConstants.user)
        }
        self.checkUser()
    }
    
    func returnError(error: String) {
        showAlertView(error: error)
        isTryAuth = false
    }
    
    
}




