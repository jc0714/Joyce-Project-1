//
//  ButtonViewController.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/22.
//

import UIKit
import Alamofire
import Kingfisher
import MJRefresh

class CatelogViewController: UIViewController{

    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var underlineView: UIView!

    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var accessoriesButton: UIButton!

    @IBOutlet weak var underlineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewCenterXConstraint: NSLayoutConstraint!

    let screenWidth = UIScreen.main.bounds.width

    var menu: [Product] = []
    var MenuProductManager = CatelogProductManager()
    var nextPage: Int = 0
    var hasMoreData: Bool = true
    var currentCategory: Int = 1 //women page

    override func viewDidLoad() {
        super.viewDidLoad()
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self

        MenuProductManager.delegate = self
        MenuProductManager.getWomenProducts()

        setUpButton()

        MJRefreshConfig.default.languageCode = "en"
        menuCollectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData))
        menuCollectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreData))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menuToDetailPage" {
            if let detailVC = segue.destination as? MenuDetailVC {
                if let indexPath = sender as? IndexPath{
                    let data = menu[indexPath.row]
                    detailVC.menu = data
                    detailVC.productIndexPath = indexPath
                }
            }
        }
    }

    @objc func setUpButton(){
        womenButton.tag = 1
        menButton.tag = 2
        accessoriesButton.tag = 3

        let buttons = buttonStackView.subviews
        for button in buttons {
            let uibutton = button as! UIButton
            uibutton.addTarget(self, action: #selector(changePage), for: .touchUpInside)
        }
    }

    @objc func loadData() {
        nextPage = 1
        self.menuCollectionView.mj_header?.endRefreshing()
        self.menuCollectionView.mj_footer?.endRefreshing()
        switch currentCategory {
            case 1:
                womenData()
            case 2:
                menData()
            case 3:
                accessoriesData()
            default:
                break
        }
    }

    @objc func loadMoreData() {
        nextPage = 0
        switch currentCategory {
            case 1:
                MenuProductManager.moreWomenProducts()
            default:
                break
        }
        self.menuCollectionView.mj_footer?.endRefreshingWithNoMoreData()
    }

    @objc func womenData(){
        menu = []
        menuCollectionView.reloadData()
        MenuProductManager.getWomenProducts()
    }

    @objc func menData(){
        menu = []
        menuCollectionView.reloadData()
        MenuProductManager.getMenProducts()
    }

    @objc func accessoriesData(){
        menu = []
        menuCollectionView.reloadData()
        MenuProductManager.getAccessoriesProducts()
    }

    //MARK: -change page animation
    @objc func changePage(sender: UIButton){
        currentCategory = sender.tag
        switch sender.tag {
            case 1:
                womenData()
            case 2:
                menData()
            case 3:
                accessoriesData()
            default:
                print("Unknown button")
        }

        underlineViewWidthConstraint.isActive = false
        underlineViewCenterXConstraint.isActive = false
        underlineViewTopConstraint.isActive = false

        underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: sender.widthAnchor)
        underlineViewCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)
        underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: sender.bottomAnchor)

        underlineViewWidthConstraint.isActive = true
        underlineViewCenterXConstraint.isActive = true
        underlineViewTopConstraint.isActive = true
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }.startAnimation()
    }
}

// MARK: - UICollectionViewDataSource
extension CatelogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menu.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = menuCollectionView.dequeueReusableCell(withReuseIdentifier: "menuCell", for: indexPath) as! CatelogCollectionViewCell
        let product = menu[indexPath.item]
        cell.menuImage.kf.setImage(with: URL(string: product.mainImage))
        cell.menuProductLabel.text = product.title
        cell.menuPriceLabel.text = "$ \(product.price)"
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CatelogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth * 0.43, height: 285)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)
    }
}

// MARK: - Fetch Products
extension CatelogViewController: CatelogProductManagerDelegate {

    func manager(_ manager: CatelogProductManager, didGetProducts products: CatelogProductResponse) {
        if nextPage == 1{
            self.menu = products.data
        } else {
            self.menu.append(contentsOf: products.data)
        }

        DispatchQueue.main.async {
            self.menuCollectionView.reloadData()
        }
    }

    func manager(_ manager: CatelogProductManager, didFailWith error: Error) {
        print("Failed to get data: \(error)")
    }
}

extension CatelogViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "menuToDetailPage", sender: indexPath)
    }
}
