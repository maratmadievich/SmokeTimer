//
//  VCStatistic.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 19.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire
import FSCalendar

class VCStatistic: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    @IBOutlet weak var viewFilter: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnShowFilter: UIBarButtonItem!
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    let urlString = UrlString()
    let jsonParser = JsonParser()
    
    var isShowFilter = false
    var user = User()
    var statistic = [Statistic]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.viewFilter.center.x  -= view.bounds.width
        getStatistic()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fsCalendar.appearance.headerDateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM yyyy", options: 0, locale: NSLocale(localeIdentifier: "ru_RU") as Locale)
        fsCalendar.locale = Locale(identifier: "ru_RU")
        fsCalendar.calendarHeaderView.calendar.locale = Locale(identifier: "ru_RU")
        tableView.tableFooterView = UIView()
    }

    
    @IBAction func btnGetStatistic(_ sender: Any) {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            getStatistic()
        }
        self.showFilterView(isShow: false)
    }
    
    
    @IBAction func btnShowFilterClicked(_ sender: Any) {
        self.showFilterView(isShow: !isShowFilter)
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.statistic.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowStatistic", for: indexPath) as! TVCStatistic
        cell.backgroundColor = UIColor.clear
        cell.labelName.text = statistic[indexPath.row].name
        cell.labelCount.text = String(describing: statistic[indexPath.row].count)
        return cell
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if (fsCalendar.selectedDates.count > 2) {
            fsCalendar.deselect(fsCalendar.selectedDates[0])
        }
    }
    
    
    // MARK: Работа с базой данных
    
    func getStatistic() {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: "Отсутствует соедиенение с Интернетом")
        } else {
            var parameters = [String: String]()
            parameters["api_token"] = self.user.token
            parameters["cafe"] = String(self.user.cafe)
            if (fsCalendar.selectedDates.count == 1) {
                 parameters["date_from"] = String(describing: (fsCalendar.selectedDates[0].timeIntervalSince1970))
            } else if (fsCalendar.selectedDates.count > 1)  {
                parameters["date_from"] = String(describing: (self.getMinDate().timeIntervalSince1970))
                parameters["date_to"] = String(describing: (self.getMaxDate().timeIntervalSince1970))
            }
            request(urlString.getUrl() + "api/CafeDelay", method: .post, parameters: parameters).responseJSON {
                response in
                self.statistic = self.jsonParser.parseDelay(JSONData: response.data!)
                self.tableView.reloadData()
            }
        }
    }
    
    
    //MARK: Вспомогательные функции
    
    func showFilterView(isShow: Bool) {
        if (isShow != isShowFilter) {
            UIView.animate(withDuration: 0.5, animations: {
                if (isShow) {
                    self.viewFilter.center.x -= self.view.bounds.width
                } else {
                    self.viewFilter.center.x += self.view.bounds.width
                }
            })
            self.isShowFilter = isShow
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
