//
//  CheckOutVC.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/3.
//

import UIKit
import CoreData

import TPDirect
import Alamofire

class CheckOutVC: UIViewController, UITableViewDataSource, UITableViewDelegate, STPaymentInfoTableViewCellDelegate, STOrderUserInputCellDelegate{
    let userDefault = UserDefaults()

    var tpdForm: TPDForm?
    func didReceiveTPDForm(_ tpdForm: TPDForm) {
        self.tpdForm = tpdForm
    }

    var list: [[String: Any]] = []
    var username: String?
    var email: String?
    var phoneNumber: String?
    var address: String?
    var shipTime: String?

    var tpdCard : TPDCard!


    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, paymentMethod: String) {
        return
    }

    func didChangeUserData(_ cell: STPaymentInfoTableViewCell, payment: String, cardNumber: String, dueDate: String, verifyCode: String) {
        return
    }
    
    func checkout(_ cell: STPaymentInfoTableViewCell) {
        return
    }
    
    @IBOutlet weak var tableView: UITableView!

    let header = ["結帳商品", "收件資訊", "付款詳情"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()

        tableView.dataSource = self
        tableView.delegate = self

        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)

        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)

        tableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)

        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)

        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))

        getAllItemsInfo()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        fetchCartItems()
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    func setBackButton(){
        let backImage = UIImage(named: "Icons_24px_Back02")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func fetchCartItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()

        do {
            cartItems = try context.fetch(fetchRequest)
            tableView.reloadData()
            let itemCount = cartItems.count

            if let tabItems = tabBarController?.tabBar.items {
                let tabItem = tabItems[2]
                if itemCount > 0 {
                    tabItem.badgeValue = "\(itemCount)"
                } else {
                    tabItem.badgeValue = nil
                }
            }

        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 67.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }

        headerView.titleLabel.text = header[section]

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2{
            return 450

        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return cartItems.count
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell

        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderProductCell.self), for: indexPath) as? STOrderProductCell else {
                return UITableViewCell()
            }
            let item = cartItems[indexPath.row]
            cell.productTitleLabel.text = item.name
            cell.priceLabel.text = item.price
            if let url = URL(string: item.imageURL ?? "") {
                cell.productImageView.kf.setImage(with: url)
            }
            cell.productSizeLabel.text = item.size
            cell.colorView.backgroundColor = UIColor(hex: item.color ?? "3A3F3F")
            cell.orderNumberLabel.text = item.number

            return cell

        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderUserInputCell.self), for: indexPath) as! STOrderUserInputCell
            cell.delegate = self
            return cell

        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPaymentInfoTableViewCell.self), for: indexPath)
            guard let paymentCell = cell as? STPaymentInfoTableViewCell else {
                return cell
            }

            paymentCell.delegate = self
            paymentCell.payButton.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
            paymentCell.payButton.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        }
        return cell

    }

    @objc func doneAction(_ sender: UIButton) {
        guard let tpdForm = tpdForm else {
            print("Error: tpdForm is nil.")
            return
        }

        tpdCard = TPDCard.setup(tpdForm)

        tpdCard.onSuccessCallback { (prime, cardInfo, cardIdentifier, merchantReferenceInfo)  in
            let result = "Prime : \(prime!)"
            primeForJSON = "\(prime!)"

            let json = self.createJSON(prime: primeForJSON, subtotal: totalPrice, total: totalPrice+60, name: self.username, phone: self.phoneNumber, email: self.email, address: self.address, time: self.shipTime, list: self.list)

            print(result)
            print("Final JSON: \(json)")

            }.onFailureCallback { (status, message) in
                let statusCode = "status : \(status),\n message : \(message)"
                print(statusCode)

        }.getPrime()
    }

    @objc func payButtonTapped(_ sender: UIButton) {
        clearAllCartItems()
        performSegue(withIdentifier: "checkOutSuccessful", sender: self)
    }

    func clearAllCartItems() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "CartItem")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save() 
        } catch {
            print("Failed to delete cart items: \(error)")
        }
    }

    func didChangeUserData(_ cell: STOrderUserInputCell, username: String, email: String, phoneNumber: String, address: String, shipTime: String) {
        (self.username, self.email, self.phoneNumber, self.address, self.shipTime) = (username, email, phoneNumber, address, shipTime)
    }

    func getAllItemsInfo() {
        for i in 0 ..< cartItems.count {
            let product = createListJSON(
                name: cartItems[i].name ?? "",
                stock: cartItems[i].stock ?? "",
                price: Int(cartItems[i].price ?? "") ?? 0,
                colorCode: cartItems[i].color ?? "",
                colorName: cartItems[i].colorName ?? "",
                size: cartItems[i].size ?? "",
                cartNumber: Int(cartItems[i].number ?? "") ?? 0,
                id: cartItems[i].id ?? ""
            )
            list.append(product)
        }
    }

    func createListJSON(name: String, stock: String, price: Int, colorCode: String, colorName: String, size: String, cartNumber: Int, id: String) -> [String: Any] {
        let listItem: [String: Any] = [
            "name": name,
            "stock": stock,
            "size": size,
            "price": price,
            "color": [
                "code": colorCode,
                "name": colorName
            ],
            "qty": cartNumber,
            "id": id
        ]
        return listItem
    }

    func createJSON(prime: String, subtotal: Int, total: Int, name: String?, phone: String?, email: String?, address: String?, time: String?, list: [[String: Any]]) -> [String: Any] {
        let coreDataOrder: [String: Any] = [
            "prime": prime,
            "order": [
                "shipping": "delivery",
                "payment": "credit_card",
                "subtotal": subtotal,
                "freight": 60,
                "total": total,
                "recipient": [
                    "name": name ?? "",
                    "phone": phone ?? "",
                    "email": email ?? "",
                    "address": address ?? "",
                    "time": time ?? ""
                ],
                "list": list
            ]
        ]
        createBill(parameters: coreDataOrder)
        return coreDataOrder

    }
    func createBill(parameters: [String: Any]) {
        let checkOutURL = URL(string: "https://api.appworks-school.tw/api/1.0/order/checkout")!
        var checkOutRequest = URLRequest(url: checkOutURL)
        checkOutRequest.httpMethod = "POST"
        checkOutRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let token = userDefault.value(forKey: "accessToken") as! String
        print("Access Token: \(token)")

        checkOutRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        checkOutRequest.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        let task = URLSession.shared.dataTask(with: checkOutRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let data = jsonResponse?["data"] as? [String: Any], let number = data["number"] as? String {
                        print("Order Number: \(number)")
                    }
                } catch {
                    print("Error parsing response: \(error.localizedDescription)")
                }
            } else {
                print("Unexpected response: \(String(describing: response))")
            }
        }
        task.resume()
    }
}

