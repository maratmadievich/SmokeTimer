//
//  AddWorkspace.swift
//  Cafe Timer
//Cafe
//  Created by Марат Нургалиев on 14.04.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit
import Alamofire

class AddWorkspace: UIView {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    var delegate: ChangeWorkspaceProtocol?
    
    var isLoad = true
    var workspaceCount = -1
    
    override func layoutSubviews() {
        
    }
    
    func loadData() {
        getSettings()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.tapView1(_:)))
        view1.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.tapView2(_:)))
        view2.addGestureRecognizer(tap2)
        
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(self.tapView3(_:)))
        view3.addGestureRecognizer(tap3)
    }
    
    
    @objc func tapView1(_ gestureReconizer: UITapGestureRecognizer) {
        if (!isLoad) {
            if (GlobalConstants.settings.workspaceCount > 1) {
                isLoad = true
                saveSettings(workspaceCount: GlobalConstants.settings.workspaceCount - 1)
            }
        }
    }
    
    
    @objc func tapView2(_ gestureReconizer: UITapGestureRecognizer) {
        if (!isLoad) {
            if (GlobalConstants.settings.workspaceCount > 2 || GlobalConstants.settings.workspaceCount < 2) {
                isLoad = true
                saveSettings(workspaceCount: 2)
            } else {
                isLoad = true
                saveSettings(workspaceCount: 1)
            }
        }
    }
    
    
    @objc func tapView3(_ gestureReconizer: UITapGestureRecognizer) {
        if (!isLoad) {
            if (GlobalConstants.settings.workspaceCount > 2) {
                isLoad = true
                saveSettings(workspaceCount: 2)
            } else {
                isLoad = true
                saveSettings(workspaceCount: 3)
            }
        }
    }
    
    
    func setLabelValues() {
        switch GlobalConstants.settings.workspaceCount {
        case 2:
            label1.text = "1"
            label2.text = "2"
            label3.text = "+"
            
            view1.isHidden = false
            view2.isHidden = false
            view3.isHidden = false
            break
            
        case 3:
            label1.text = "1"
            label2.text = "2"
            label3.text = "3"
            
            view1.isHidden = false
            view2.isHidden = false
            view3.isHidden = false
            break

        default:
            label1.text = "1"
            label2.text = "+"
            label3.text = ""
            
            view1.isHidden = false
            view2.isHidden = false
            view3.isHidden = true
            break
        }
    }
    
    
    
    // MARK: Работа с базой данных
    
    func getSettings() {
        if (!Connectivity.isConnectedToInternet) {
            delegate?.cafeEditorShowAlert(error: "Отсутствует соедиенение с Интернетом")
        } else {
            GlobalConstants.alamofireResponse.getSettings(delegate: self)
//            let parameters = ["api_token":  self.user.token, "cafe":String(self.user.cafe)]
//            request(urlString.getUrl() + "api/CafeDetailed", method: .post, parameters: parameters).responseJSON {
//                response in
//                self.settings = self.jsonParser.parseSettings(JSONData: response.data!, cafe: self.user.cafe)
//                if (self.settings.error.count > 0) {
//                    self.delegate?.cafeEditorShowAlert(error: self.settings.error)
//                } else {
//                    self.delegate?.cafeEditorChangeWorkspaceCount(settings: self.settings)
//                }
//                self.isLoad = false
//                self.setLabelValues()
//            }
        }
    }
    
    
    func saveSettings(workspaceCount: Int) {
        if (!Connectivity.isConnectedToInternet) {
            delegate?.cafeEditorShowAlert(error: "Отсутствует соедиенение с Интернетом")
            isLoad = false
        } else {
            self.workspaceCount = workspaceCount
            var parameters = Parameters()
            parameters["api_token"] = GlobalConstants.user.token
            parameters["cafe"] = GlobalConstants.user.cafe
            parameters["workspace_count"] = workspaceCount
            GlobalConstants.alamofireResponse.saveSettings(parameters: parameters, delegate: self)
//            let parameters = ["api_token":  self.user.token,
//                              "cafe": String(self.user.cafe),
//                              "workspace_count": String(describing: workspaceCount)]
//            request(urlString.getUrl() + "api/CafeUpdate", method: .post, parameters: parameters).responseJSON {
//                response in
//                let response = self.jsonParser.parseEditDelete(JSONData: response.data!)
//                if (response.isError) {
//                    self.delegate?.cafeEditorShowAlert(error: response.text)
//                } else {
//                    self.settings.workspaceCount = workspaceCount
//                    self.delegate?.cafeEditorChangeWorkspaceCount(settings: self.settings)
//                    self.isLoad = false
//                    self.setLabelValues()
//                }
//            }
        }
    }

}

extension AddWorkspace: BackEndSettingsProtocol {
    
    func returnSettingsSuccess() {
        workspaceCount = GlobalConstants.settings.workspaceCount
        self.delegate?.cafeEditorChangeWorkspaceCount(settings: GlobalConstants.settings)
        self.isLoad = false
        self.setLabelValues()
    }
    
    func returnUpdateSuccess() {
        GlobalConstants.settings.workspaceCount = workspaceCount
        self.delegate?.cafeEditorChangeWorkspaceCount(settings: GlobalConstants.settings)
        self.isLoad = false
        self.setLabelValues()
    }
    
    func returnError(error: String) {
        self.delegate?.cafeEditorShowAlert(error: error)
    }
    
    
}




