//
//  VCMenu.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 09.05.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class VCMenu: UIViewController, AlertExitProtocol {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    let urlString = UrlString()
    
    var user = User()
    var error = "Отсутствует соединение с Интернетом"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnSettingsClicked(_ sender: Any) {
        if (!Connectivity.isConnectedToInternet) {
             showAlertView(error: error)
        } else {
            self.performSegue(withIdentifier: "showSettings", sender: nil)
        }
    }
    

    @IBAction func btnStatisticClicked(_ sender: Any) {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: error)
        } else {
        self.performSegue(withIdentifier: "showStatistic", sender: nil)
        }
    }
    
    
    @IBAction func btnNowClicked(_ sender: Any) {
        if (!Connectivity.isConnectedToInternet) {
            showAlertView(error: error)
        } else {
            self.performSegue(withIdentifier: "showNow", sender: nil)
        }
    }
    
    
    @IBAction func btnExitClicked(_ sender: Any) {
        if let viewAlertExit = Bundle.main.loadNibNamed("AlertExit", owner: self, options: nil)?.first as? AlertExit {
            let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            viewAlertExit.frame = rect
            viewAlertExit.forPhone = true
            viewAlertExit.delegate = self
            view.addSubview(viewAlertExit)
        }
    }
    
    
    func responseExit(response: Int) {
        if (response > 0) {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "showSettings") {
            let vc = segue.destination as! VCSettings
            vc.user = self.user
        }
        if (segue.identifier == "showStatistic") {
            let vc = segue.destination as! VCStatistic
            vc.user = self.user
        }
        if (segue.identifier == "showNow") {
            let vc = segue.destination as! VCNowTable
            vc.user = self.user
        }
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = UIColor.white
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
