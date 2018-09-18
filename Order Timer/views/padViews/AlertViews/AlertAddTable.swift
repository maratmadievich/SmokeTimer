//
//  AlertAddTable.swift
//  Cafe Timer
//
//  Created by Марат Нургалиев on 11.05.2018.
//  Copyright © 2018 Марат Нургалиев. All rights reserved.
//

import UIKit

class AlertAddTable: UIView {
    
    var delegate: AlertAddTableProtocol?
    
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var viewVertical: UIView!
    @IBOutlet weak var viewHorizontal: UIView!
    
    @IBOutlet weak var textFieldSize: UITextField!
    @IBOutlet weak var textFieldX: UITextField!
    @IBOutlet weak var textFieldY: UITextField!
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var viewSize: UIView!
    @IBOutlet weak var circle: CornerView!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var labelAlert: UILabel!
    
    var spaceWidth = -1.0
    var spaceHeight = -1.0
    var minTableSIze = -1.0
    
    var selectedType = -1
    
    
    
    override func layoutSubviews() {
        
        circle.cornerRadius = circle.frame.size.width / 2
        
//        textFieldSize.attributedPlaceholder = NSAttributedString(string: "Размер", attributes:[NSForegroundColorAttributeName: UIColor.gray])
//        textFieldName.attributedPlaceholder = NSAttributedString(string: "Название", attributes:[NSForegroundColorAttributeName: UIColor.gray])
//        textFieldX.attributedPlaceholder = NSAttributedString(string: "X", attributes:[NSForegroundColorAttributeName: UIColor.gray])
//        textFieldY.attributedPlaceholder = NSAttributedString(string: "Y", attributes:[NSForegroundColorAttributeName: UIColor.gray])
    }
    
    
    @IBAction func btnCreateClicked(_ sender: Any) {
        if (selectedType > -1) {
            var error = false
            var size = 0.0
            if (selectedType > 0) {
                if (textFieldSize.text?.count == 0) {
                    showAlertView(error: "Необходимо ввести размер столика")
                    error = true
                } else {
                    size = Double(textFieldSize.text!)!
                    if (size < minTableSIze * 2) {
                        let showMin = Int(minTableSIze * 2)
                        showAlertView(error: "Размер столика должен превышать \(showMin)")
                        error = true
                    } else {
                        if (selectedType == 1) {
                            if (size > spaceHeight) {
                                showAlertView(error: "Размер столика не должен превышать \(spaceHeight)")
                                error = true
                            }
                            size = size / spaceHeight
                        } else if (selectedType == 2) {
                            if (size > spaceWidth) {
                                showAlertView(error: "Размер столика не должен превышать \(spaceWidth)")
                                error = true
                            }
                            size = size / spaceWidth
                            size = -size
                        }
                    }
                }
            }
            if (!error) {
                delegate?.addAlertTable(type: selectedType, name: textFieldName.text!, size: CGFloat(size))
                self.removeFromSuperview()
            }
        } else {
            showAlertView(error: "Необходимо выбрать тип столика")
        }
    }
    
    
    @IBAction func btnCancelClicked(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    
    @IBAction func btnCircleClicked(_ sender: Any) {
        if (selectedType != 0) {
            selectedType = 0
            clearViews()
            viewCircle.backgroundColor = Table().getColor(status: 1)
            viewSize.isHidden = true
        }
    }
    
    
    @IBAction func btnVerticalClicked(_ sender: Any) {
        if (selectedType != 1) {
            selectedType = 1
            clearViews()
            viewVertical.backgroundColor = Table().getColor(status: 1)
            textFieldSize.text = ""
            viewSize.isHidden = false
        }
    }
    
    
    @IBAction func btnHorizontalClicked(_ sender: Any) {
        if (selectedType != 2) {
            selectedType = 2
            clearViews()
            viewHorizontal.backgroundColor = Table().getColor(status: 1)
            textFieldSize.text = ""
            viewSize.isHidden = false
        }
    }
    
    
    private func clearViews() {
        viewCircle.backgroundColor = Table().getColor(status: 0)
        viewVertical.backgroundColor = Table().getColor(status: 0)
        viewHorizontal.backgroundColor = Table().getColor(status: 0)
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
