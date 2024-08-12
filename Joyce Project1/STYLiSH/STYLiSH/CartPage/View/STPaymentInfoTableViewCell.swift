//
//  STPaymentInfoTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/26.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit
import TPDirect

private enum PaymentMethod: String {
    case creditCard = "信用卡付款"
    case cash = "貨到付款"
}

protocol STPaymentInfoTableViewCellDelegate: AnyObject {
    func didReceiveTPDForm(_ tpdForm: TPDForm)
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, paymentMethod: String)

    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    )

    
    func checkout(_ cell:STPaymentInfoTableViewCell)
}

var primeForJSON : String = ""

class STPaymentInfoTableViewCell: UITableViewCell, STOrderUserInputCellDelegate {
    var list: [[String: Any]] = []
    var username: String?
    var useremail: String?
    var phoneNumber: String?
    var useraddress: String?
    var shipTime: String?

    @IBOutlet weak var paymentTextField: UITextField! {
        
        didSet {
        
            let shipPicker = UIPickerView()
            
            shipPicker.dataSource = self
            
            shipPicker.delegate = self

            paymentTextField.inputView = shipPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            paymentTextField.rightView = button
            
            paymentTextField.rightViewMode = .always
            
            paymentTextField.delegate = self
            
            paymentTextField.text = PaymentMethod.cash.rawValue
        }
    }
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var shipPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var productAmountLabel: UILabel!
    
    @IBOutlet weak var topDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var creditView: UIView! {
        didSet {
            creditView.isHidden = true
        }
    }

    @IBOutlet weak var payButton: UIButton!

    var tpdForm : TPDForm!

    private let paymentMethod: [PaymentMethod] = [.cash, .creditCard]
    
    weak var delegate: STPaymentInfoTableViewCellDelegate?

    override func awakeFromNib() {
        layoutCellWith()
        super.awakeFromNib()
        // 1. Setup TPDForm With Your Customized CardView, Recommend(width:260, height:80)
        tpdForm = TPDForm.setup(withContainer: creditView)

        // 2. Setup TPDForm Text Color
        tpdForm.setErrorColor(colorWithRGB(rgbString: "D62D20", alpha: 1.0))
        tpdForm.setOkColor(colorWithRGB(rgbString: "008744", alpha: 1.0))
        tpdForm.setNormalColor(colorWithRGB(rgbString: "0F0F0F", alpha: 1.0))

        // 3. Setup TPDForm onFormUpdated Callback
        tpdForm.onFormUpdated { (status) in
            weak var weakSelf = self
            weakSelf?.payButton.isEnabled = status.isCanGetPrime()
            weakSelf?.payButton.alpha     = (status.isCanGetPrime()) ? 1.0 : 0.25

        }

        payButton.isEnabled = false
        payButton.alpha     = 0.25
        
        DispatchQueue.main.async {
               self.delegate?.didReceiveTPDForm(self.tpdForm)
           }
    }

    func didChangeUserData(
        _ cell: STOrderUserInputCell, username: String, email: String, phoneNumber: String, address: String, shipTime: String){
        let allFieldsFilled = !username.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !address.isEmpty && !shipTime.isEmpty

        payButton.isEnabled = allFieldsFilled
        payButton.alpha = allFieldsFilled ? 1.0 : 0.25
    }

    func layoutCellWith() {
        productPriceLabel.text = "NT$ \(totalPrice)"
        shipPriceLabel.text = "NT$ 60"
        totalPriceLabel.text = "NT$ \(totalPrice+60)"
        productAmountLabel.text = "總計 (\(totalNumber)樣商品)"
    }
    
    @IBAction func checkout() {
        delegate?.checkout(self)
    }

    func colorWithRGB(rgbString:String!, alpha:CGFloat!) -> UIColor! {

        let scanner = Scanner.init(string: rgbString.lowercased())
        var baseColor:UInt64 = UInt64()
        scanner.scanHexInt64(&baseColor)

        let red     = ((CGFloat)((baseColor & 0xFF0000) >> 16)) / 255.0
        let green   = ((CGFloat)((baseColor & 0xFF00) >> 8)) / 255.0
        let blue    = ((CGFloat)(baseColor & 0xFF)) / 255.0

        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }

}

extension STPaymentInfoTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int
    {
        return 2
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String?
    {
        
        return paymentMethod[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        paymentTextField.text = paymentMethod[row].rawValue
    }
    
    private func manipulateHeight(_ distance: CGFloat) {
        topDistanceConstraint.constant = distance

        if let selectedMethod = paymentMethod.first(where: { $0.rawValue == paymentTextField.text }) {
            delegate?.didChangePaymentMethod(self, paymentMethod: selectedMethod.rawValue)
        }
    }
}

extension STPaymentInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField != paymentTextField {
            return
        }
        
        guard
            let text = textField.text,
            let payment = PaymentMethod(rawValue: text) else
        {
            return
        }
        
        switch payment {
        case .cash:
            manipulateHeight(44)
            creditView.isHidden = true
            payButton.isEnabled = true
            payButton.alpha = 1.0
            print("選擇貨到付款")

        case .creditCard:
            manipulateHeight(160)
            creditView.isHidden = false
            print("選擇信用卡")
        }
    }
}
