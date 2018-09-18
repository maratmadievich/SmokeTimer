//
//  VCSettings.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 08.02.18.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class VCSettings: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textFieldStartOrder: UITextField!
    @IBOutlet weak var textFieldFiveMinutes: UITextField!
    @IBOutlet weak var textFieldWorkTimer: UITextField!
    @IBOutlet weak var textFieldCountIterations: UITextField!
    @IBOutlet weak var textFieldOrderCount: UITextField!
    @IBOutlet weak var textFieldDelay: UITextField!
    
    let urlString = UrlString()
    let jsonParser = JsonParser()
    
    var user = User()
    var settings = Settings()
    
    
    override func viewWillAppear(_ animated: Bool) {
        getSettings()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        mainView.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    // MARK: Обработка кликов кнопок
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        view.endEditing(true)
        checkTimerData()
//        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    
    // MARK: Работа с базой данных
    
    func getSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
            print ("settings_url:\(urlString.getUrl())api/CafeDetailed")
            print ("settings_params:\(parameters)")
            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
                response in
                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
                if (self.settings.error.count > 0) {
                    self.showAlertView(error: self.settings.error)
                } else {
                    self.textFieldStartOrder.text = String(self.settings.timeStartOrder)
                    self.textFieldFiveMinutes.text = String(self.settings.timeFiveMinutes)
                    self.textFieldWorkTimer.text = String(self.settings.timeWorkTimer)
                    self.textFieldCountIterations.text = String(self.settings.countIterations)
                    self.textFieldCountIterations.text = String(self.settings.countIterations)
                    self.textFieldOrderCount.text = String(self.settings.maxOrder)
                    self.textFieldDelay.text = String(self.settings.maxDelay)
                }
            }
        }
    }
    
    
    func saveSettings() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe": String(self.user.cafe),
                              "order_timer": textFieldStartOrder.text!,
                              "minutes_timer":  textFieldFiveMinutes.text!,
                              "work_timer":  textFieldWorkTimer.text!,
                              "timer_count":  textFieldCountIterations.text!,
                              "max_order":  textFieldOrderCount.text!,
                              "max_delay":  textFieldDelay.text!]
            request(urlString.getUrl() + "api/CafeUpdate", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.showAlertView(error: response.text)
                } else {
//                    self.gotoSegue()
                    self.showAlertView(error: "Сохранение прошло успешно")
                }
            }
        }
    }
    
    
    // MARK: Вспомогательные функции
    
    func checkTimerData() {
        if (textFieldStartOrder.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"Принятие заказа\"")
        } else if (textFieldFiveMinutes.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"5 минут\"")
        } else if (textFieldWorkTimer.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"Рабочий\"")
        } else if (textFieldCountIterations.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"Количество промежуточных таймеров\"")
        } else if (textFieldOrderCount.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"Количество заказов на 1 столик\"")
        } else if (textFieldDelay.text!.count == 0) {
            showAlertView(error: "Не заполнено поле \"Мах. время просрочки таймера\"")
        } else if (Int(textFieldStartOrder.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else if (Int(textFieldFiveMinutes.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else if (Int(textFieldWorkTimer.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else if (Int(textFieldCountIterations.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else if (Int(textFieldOrderCount.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else if (Int(textFieldDelay.text!)! < 1) {
            showAlertView(error: "Значение полей должно быть больше 0")
        } else {
            saveSettings()
        }
    }
    
    
//    func gotoSegue() {
//        self.performSegue(withIdentifier: "showWaiters", sender: nil)
//    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showWaiters") {
            let vc = segue.destination as! VCWaiters
            vc.user = self.user
            vc.settings = self.settings
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
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
