//
//  ViewController.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/17.
//

import UIKit
import Kingfisher
import MJRefresh
import CoreData

struct OddProduct {
    let imageName: String
    let productName: String
    let thickness: String
    let flex: String
}

struct EvenProduct {
    let imageName_1: String
    let imageName_2: String
    let imageName_3: String
    let imageName_4: String
    let productName_b: String
    let thickness_b: String
    let flex_b: String
}


// MARK: ViewController
class ViewController: UIViewController{

    @IBOutlet weak var tableView : UITableView!

    var hot: [MarketHots] = []
    var marketManager = MarketManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        marketManager.delegate = self
        marketManager.getMarketingHots()

        updateBadge()

        MJRefreshConfig.default.languageCode = "en"
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
    }
    
    // MARK: segue to detail page
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushToDetailPage" {
            if let detailVC = segue.destination as? DetailPageVC {
                if let indexPath = sender as? IndexPath{
                    let data = hot[indexPath.section].products[indexPath.row]
                    detailVC.hot = data
                    detailVC.productIndexPath = indexPath
                }
            }
        }
    }

    @objc func loadData() {
        marketManager.getMarketingHots()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tableView.mj_header?.endRefreshing()
        }
    }

    func updateBadge(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()

        do {
            cartItems = try context.fetch(fetchRequest)
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

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{

    // MARK: Tableview cell
    func numberOfSections(in tableView: UITableView) -> Int {
        return hot.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hot[section].products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 != 1 {
            let product = hot[indexPath.section].products[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OddTableViewCell
            cell.update(with: product)
            return cell
        } else {
            let product = hot[indexPath.section].products[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "EvenCell", for: indexPath) as! EvenTableViewCell
            cell.update(with: product)
            return cell
        }
    }

    // MARK: Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return hot[section].title
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 15, y: 5, width: tableView.frame.width - 30, height: 30)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)

        headerView.addSubview(label)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PushToDetailPage", sender: indexPath)
    }
}

extension ViewController: MarketManagerDelegate{

    func manager(_ manager: MarketManager, didGet marketingHots: [MarketHots]) {
        self.hot = marketingHots
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func manager(_ manager: MarketManager, didFailWith error: any Error) {
        print("Failed to get data: \(error)")
    }
}
