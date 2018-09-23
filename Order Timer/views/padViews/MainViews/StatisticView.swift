//
//  StatisticView.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 12.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import FSCalendar

class StatisticView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    var isByChecked = false
    var isSinseChecked = false
    
    var statistic = [Statistic]()

    
    override func layoutSubviews() {
        
    }
    
    
    func loadData() {
        tableView.delegate = self
        tableView.dataSource = self
        
        fsCalendar.delegate = self
        fsCalendar.dataSource = self
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        //        fsCalendar.appearance.headerDateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: NSLocale(localeIdentifier: "ru_RU") as Locale)
        fsCalendar.locale = Locale(identifier: "ru_RU")
        fsCalendar.calendarHeaderView.calendar.locale = Locale(identifier: "ru_RU")
        
        prepareGetStatistic()
    }
    
    
    func dismissKeyboard(_ gestureReconizer: UITapGestureRecognizer) {
        self.endEditing(true)
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if (fsCalendar.selectedDates.count > 2) {
            fsCalendar.deselect(fsCalendar.selectedDates[0])
        }
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (textField.text?.count == 2) || (textField.text?.count == 5) {
            if !(string == "") {
                textField.text = textField.text! + "."
            }
        }
        return !(textField.text!.count > 9 && (string.count) > range.length)
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.statistic.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("RowStatistic", owner: self, options: nil)?.first as! TVCStatistic
        cell.backgroundColor = UIColor.clear
        cell.labelName.text = statistic[indexPath.row].name
        cell.labelCount.text = String(statistic[indexPath.row].count)
        return cell
    }
    
    
    @IBAction func btnSetClicked(_ sender: Any) {
        self.endEditing(true)
        prepareGetStatistic()
    }
    
    
    func prepareGetStatistic() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            if (fsCalendar.selectedDates.count == 1) {
                parameters["date_from"] = fsCalendar.selectedDates[0].timeIntervalSince1970
            } else if (fsCalendar.selectedDates.count > 1)  {
                parameters["date_from"] = self.getMinDate().timeIntervalSince1970
                parameters["date_to"] = self.getMaxDate().timeIntervalSince1970
            }
            GlobalConstants.alamofireResponse.getDelays(parameters: parameters, delegate: self)
            
            
//            parameters["api_token"] = self.user.token
//            parameters["cafe"] = String(self.user.cafe)
//            if (fsCalendar.selectedDates.count == 1) {
//                parameters["date_from"] = String(describing: (fsCalendar.selectedDates[0].timeIntervalSince1970))
//            } else if (fsCalendar.selectedDates.count > 1)  {
//                parameters["date_from"] = String(describing: (self.getMinDate().timeIntervalSince1970))
//                parameters["date_to"] = String(describing: (self.getMaxDate().timeIntervalSince1970))
//            }
//            request(urlString.getUrl() + "api/CafeDelay", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.statistic = self.jsonParser.parseDelay(JSONData: response.data!)
//                self.tableView.reloadData()
//            }
        }
    }
    
    
    func getMinDate() -> Date {
        var minDate = fsCalendar.selectedDates[0]
        for date in fsCalendar.selectedDates {
            if (minDate > date) {
                minDate = date
            }
        }
        return minDate
    }
    
    
    func getMaxDate() -> Date {
        var maxDate = fsCalendar.selectedDates[0]
        for date in fsCalendar.selectedDates {
            if (maxDate < date) {
                maxDate = date
            }
        }
        return maxDate
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

extension StatisticView: BackEndDelaysProtocol {
    func returnMy(delays: [Statistic]) {
        self.statistic = delays
        self.tableView.reloadData()
    }
    
    func returnAdd(delay: Delay) {}
    func returnError(error: String) {}
    
    
}



