//
//  VCWaiters.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 16.03.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class VCWaiters: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    let urlString = UrlString()
    let jsonParser = JsonParser()
    
    var user = User()
    var settings = Settings()
    
    var waiters = [Waiter]()
    
    var isEdit = false
    var selectedIndexPath: IndexPath?
    
    
    override func viewWillAppear(_ animated: Bool) {
        getWaiters()
        setButtonHidden(isHidden: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    
    // MARK: Функции таблицы
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.waiters.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowWaiter", for: indexPath) as! TVCWaiter
        cell.labelName.text = waiters[indexPath.row].name
        return cell
    }
    
    
    @objc func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        setButtonHidden(isHidden: false)
    }
    
    
    
    @IBAction func btnAddClicked(_ sender: Any) {
        isEdit = false
        self.performSegue(withIdentifier: "showEdit", sender: nil)
    }
    
    
    @IBAction func btnEditClicked(_ sender: Any) {
        isEdit = true
        self.performSegue(withIdentifier: "showEdit", sender: nil)
    }
    
    
    @IBAction func btnDeleteClicked(_ sender: Any) {
        showDeleteAlert()
    }
    
    
    @IBAction func btnSaveClicked(_ sender: Any) {
        if (waiters.count == 0) {
            showEmptyFieldAlert(error: "Для корректной работы приложения должен быть назначен хотя бы 1 официант")
        } else {
            self.performSegue(withIdentifier: "unwindStart", sender: nil)
        }
    }
    
    // MARK: Работа с базой данных
    
    func getWaiters() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
            request(urlString.getUrl() + "api/CafeWaiter", method: .post, parameters: parameters).responseJSON {
                response in
                self.waiters = self.jsonParser.parseWaiters(JSONData: response.data!)
                self.tableView.reloadData()
            }
        }
    }
    
    
    func deleteWaiter() {
        if (!Connectivity.isConnectedToInternet) {
            self.showEmptyFieldAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            let parameters = ["api_token":  self.user.token,
                              "cafe":String(self.user.cafe),
                              "user":String(self.waiters[(self.selectedIndexPath?.row)!].id)]
            request(urlString.getUrl() + "api/DeleteWaiter", method: .post, parameters: parameters).responseJSON {
                response in
                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
                if (response.isError) {
                    self.showEmptyFieldAlert(error: response.text)
                } else {
                    self.setButtonHidden(isHidden: true)
                    self.tableView.deselectRow(at: self.selectedIndexPath!, animated: true)
                    self.waiters.remove(at: self.selectedIndexPath!.row)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    // MARK: Вспомогательные функции
    
    func setButtonHidden(isHidden: Bool) {
        btnDelete.isHidden = isHidden
        btnEdit.isHidden = isHidden
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showEdit") {
            let vc = segue.destination as! VCEditWaiter
            vc.user = self.user
            vc.settings = self.settings
            if (isEdit) {
                vc.isEdit = isEdit
                vc.waiter = self.waiters[(self.selectedIndexPath?.row)!]
            }
        }
        let backItem = UIBarButtonItem()
        backItem.title = "Назад"
        navigationItem.backBarButtonItem = backItem
    }
    
    
    // MARK: Алерты
    
    func showEmptyFieldAlert(error: String) {
        let alert = UIAlertController(title: "Внимание", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func showDeleteAlert() {
        let alert = UIAlertController(title: "Внимание", message: "Вы действительно хотите удалить официанта " + self.waiters[(selectedIndexPath?.row)!].name, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Удалить", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction!) in
            self.deleteWaiter()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
