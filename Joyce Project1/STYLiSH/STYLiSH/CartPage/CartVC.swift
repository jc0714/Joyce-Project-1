//
//  CartVC.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/1.
//
import UIKit
import CoreData
import Kingfisher
import FacebookLogin
import StatusAlert

var cartItems: [CartItem] = []
var totalPrice: Int = 0
var totalNumber: Int = 0

class CartVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var CartTableView: UITableView!
    @IBOutlet weak var goToCheckButton: UIButton!
    @IBOutlet weak var behindButtonView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCartItems()

        CartTableView.register(CartTableViewCell.self, forCellReuseIdentifier: "cartItemCell")

        CartTableView.separatorStyle = .none
        CartTableView.delegate = self
        CartTableView.dataSource = self

        CartTableView.rowHeight = 150
        CartTableView.reloadData()

        setUpUI()
    }

    override func viewIsAppearing(_ animated: Bool) {
        fetchCartItems()
    }

    @IBAction func logOutButtonTapped(_ sender: UIBarButtonItem) {
        let loginManager = LoginManager()
        loginManager.logOut()
        print("Logged out from Facebook")

        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(systemName: "hand.raised")
        statusAlert.title = "Log out, see u next time!"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.showInKeyWindow()
    }

    @IBAction func goToCheckButtonTapped(_ sender: Any) {
        let totalAmount = calculateTotalAmount()
        print("Total Amount: \(totalAmount)")
    }

    func calculateTotalAmount() -> Int {
        totalPrice = 0
        for item in cartItems {
            let priceString = item.price?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "1"

            if let price = Int(priceString), let number = Int(item.number ?? "1") {
                totalPrice += price * number
                totalNumber += number
            }
        }
        return totalPrice
    }

    func fetchCartItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        updateGoToCheckButtonState()

        do {
            cartItems = try context.fetch(fetchRequest)
            CartTableView.reloadData()
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

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartItemCell", for: indexPath) as! CartTableViewCell

        let item = cartItems[indexPath.row]
        cell.productNameLabel.text = item.name
        cell.productPriceLabel.text = item.price
        if let url = URL(string: item.imageURL ?? "") {
            cell.productImageView.kf.setImage(with: url)
        }
        cell.sizeLabel.text = item.size
        cell.colorView.backgroundColor = UIColor(hex: "\(item.color ?? "3A3F3F")")
        cell.numberTextField.text = item.number
        
        cell.productId = item.id
        cell.colorName = item.colorName

        cell.stock = item.stock

        cell.onDeleteButtonTapped = { [weak self] in self?.deleteProduct(at: indexPath)}
        cell.onAddButtonTapped = { [weak self] newValue in
            self?.updateCartItemNumber(for: indexPath, with: newValue)
        }
        cell.onSubtractButtonTapped = {[weak self] newValue in
            self?.updateCartItemNumber(for: indexPath, with: newValue)
        }

        return cell
    }

    func deleteProduct(at indexPath: IndexPath) {
        guard indexPath.row < cartItems.count else { return }
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let itemToDelete = cartItems[indexPath.row]

        context.delete(itemToDelete)

        do {
            try context.save()
        } catch let error as NSError {
            print("Could not delete \(error), \(error.userInfo)")
        }
        cartItems.remove(at: indexPath.row)
        CartTableView.deleteRows(at: [indexPath], with: .automatic)
        updateGoToCheckButtonState()
        fetchCartItems()
    }

    func updateCartItemNumber(for indexPath: IndexPath, with newValue: Int) {
        cartItems[indexPath.row].number = "\(newValue)"

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        do {
            try context.save()
        } catch {
            print("Failed to update item number in Core Data: \(error)")
        }
        CartTableView.reloadRows(at: [indexPath], with: .none)
        fetchCartItems()
    }

    // MARK: - Table view delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func setUpUI() {
        goToCheckButton.backgroundColor = .black

        goToCheckButton.setTitleColor(.white, for: .normal)
        goToCheckButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            goToCheckButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goToCheckButton.centerYAnchor.constraint(equalTo: behindButtonView.centerYAnchor),
            goToCheckButton.widthAnchor.constraint(equalToConstant: 343),
            goToCheckButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func updateGoToCheckButtonState() {
        if cartItems.count == 0 {
            goToCheckButton.setTitle("歡迎選購，再來結帳", for: .normal)
            goToCheckButton.isUserInteractionEnabled = false
        } else {
            goToCheckButton.setTitle("前往結帳", for: .normal)
            goToCheckButton.isUserInteractionEnabled = true
        }
    }

}

