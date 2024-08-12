//
//  DetailPageVC.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/26.
//

import UIKit
import Kingfisher
import StatusAlert
import CoreData

class DetailPageVC: UIViewController, UICollectionViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITableViewDelegate {

    var hot: Product?
    var marketManager = MarketManager()
    var productIndexPath: IndexPath?
    var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    var labels: [UILabel] = []
    var pageControl: UIPageControl!

    let shopPageTableView = UITableView()
    var shopPageViewTopConstraint: NSLayoutConstraint!
    var shopPageViewBottomConstraint: NSLayoutConstraint!
    var makeDarkView = UIView()
    
    let buttonBackground = UIView()
    let buttonLine = UIView()
    let button = UIButton()
    var cell2: ShopPageTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        setBackButton()
        setupScrollView()
        setupCollectionView()
        setupLabels()
        setupPageControl()
        setButton()

        shopPageTableView.dataSource = self
        shopPageTableView.delegate = self

        shopPageTableView.translatesAutoresizingMaskIntoConstraints = false
        shopPageTableView.register(ShopPageTableViewCell.self, forCellReuseIdentifier: "ShopPageTableViewCell")
    }

    func setBackButton(){
        let backImage = UIImage(named: "Icons_44px_Back01")?.withRenderingMode(.alwaysOriginal)
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }

    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = .zero
        scrollView.contentInsetAdjustmentBehavior = .never // 關閉自動加上 status bar 的功能
        makeDarkView.backgroundColor = .black
        makeDarkView.alpha = 0.5
        makeDarkView.isHidden = true
        makeDarkView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(scrollView)
        self.view.addSubview(makeDarkView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90)
        ])

        NSLayoutConstraint.activate([
            makeDarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            makeDarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            makeDarkView.topAnchor.constraint(equalTo: view.topAnchor),
            makeDarkView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90)
        ])

        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height * 2)
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height / 2)
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero

        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height/2), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .white
        collectionView.contentInset = .zero
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        
        scrollView.addSubview(collectionView)
    }

    func setupLabels() {
        guard let product = hot else {
            return
        }
        // 商品名稱、價格在同一 row
        var labelsY = collectionView.frame.maxY + 20

        let titleLabel = UILabel()
        titleLabel.text = "\(product.title)"
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.frame = CGRect(x: 15, y: labelsY, width: view.frame.width / 3*2, height: 30)

        let priceLabel = UILabel()
        priceLabel.text = "NT$ \(product.price)"
        priceLabel.font = UIFont.systemFont(ofSize: 20)
        priceLabel.textAlignment = .right
        priceLabel.frame = CGRect(x: view.frame.width / 2 + 15, y: labelsY, width: view.frame.width / 2 - 30, height: 30)

        scrollView.addSubview(titleLabel)
        scrollView.addSubview(priceLabel)

        labelsY += 30 + 10

        let otherTitles = ["\(product.id)", "\(product.story)", "顏色 | ", "尺寸 | ", "庫存 | ", "材質 | \(product.texture)", "洗滌 | \(product.wash)", "產地 | \(product.place)", "備註 | \(product.note)"]

        func makeGreyLine(in text: String) -> NSMutableAttributedString {
            let attributedString = NSMutableAttributedString(string: text)
            let separator = " | "
            let components = text.components(separatedBy: separator)

            var currentLocation = 0
            for component in components {
                let range = NSRange(location: currentLocation, length: component.count)
                attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                currentLocation += component.count
                if currentLocation < attributedString.length {
                    let separatorRange = NSRange(location: currentLocation, length: separator.count)
                    attributedString.addAttribute(.foregroundColor, value: UIColor.lightGray, range: separatorRange)
                    currentLocation += separator.count
                }
            }
            return attributedString
        }

        for title in otherTitles {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.textAlignment = .left
            label.numberOfLines = 0
            scrollView.addSubview(label)
            let attributedText: NSMutableAttributedString

            if title == "\(product.id)" {
                label.textColor = .lightGray
                label.text = title
                let maxSize = CGSize(width: view.frame.width - 30, height: CGFloat.greatestFiniteMagnitude)
                let estimatedSize = label.sizeThatFits(maxSize)
                label.frame = CGRect(x: 15, y: labelsY - 12, width: view.frame.width - 30, height: estimatedSize.height)
            } else {
                if title == "顏色 | " {
                    var distance = 65
                    for color in product.colors {
                        let colorSquare = UIView()

                        colorSquare.backgroundColor = UIColor(hex: color.code)
                        colorSquare.layer.borderWidth = 1
                        colorSquare.layer.borderColor = UIColor.black.cgColor
                        colorSquare.translatesAutoresizingMaskIntoConstraints = false
                        scrollView.addSubview(colorSquare)

                        NSLayoutConstraint.activate([
                            colorSquare.widthAnchor.constraint(equalToConstant: 24),
                            colorSquare.heightAnchor.constraint(equalToConstant: 24),
                            colorSquare.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: CGFloat(distance)),
                            colorSquare.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: labelsY),
                        ])
                        distance += 40
                    }
                    attributedText = makeGreyLine(in: title)
                    label.attributedText = attributedText
                } else if title == "尺寸 | " {
                    var sizesText = title
                    sizesText += product.sizes[0] + "-" + product.sizes[product.sizes.count - 1]
                    attributedText = makeGreyLine(in: sizesText)
                    label.attributedText = attributedText
                } else if title == "庫存 | " {
                    let stockText = title
                    var sumStock = 0
                    for stock in 0..<product.variants.count {
                        sumStock += product.variants[stock].stock
                    }
                    attributedText = makeGreyLine(in: stockText + String(sumStock))
                    label.attributedText = attributedText
                } else {
                    attributedText = makeGreyLine(in: title)
                    label.attributedText = attributedText
                }
                let maxSize = CGSize(width: view.frame.width - 30, height: CGFloat.greatestFiniteMagnitude)
                let estimatedSize = label.sizeThatFits(maxSize)
                label.frame = CGRect(x: 15, y: labelsY, width: view.frame.width - 30, height: estimatedSize.height)
            }
            scrollView.addSubview(label)
            labelsY += label.frame.height + 15
        }

        scrollView.contentSize = CGSize(width: view.frame.width, height: labelsY)
    }
    
    func setButton() {
        buttonBackground.backgroundColor = .white
        buttonBackground.translatesAutoresizingMaskIntoConstraints = false

        buttonLine.backgroundColor = .black
        buttonLine.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle("加入購物車", for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        shopPageTableView.backgroundColor = .white
        shopPageTableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(shopPageTableView)
        view.addSubview(buttonBackground)
        view.addSubview(buttonLine)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            buttonBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            buttonBackground.heightAnchor.constraint(equalToConstant: 90)
        ])

        NSLayoutConstraint.activate([
            buttonLine.leadingAnchor.constraint(equalTo: buttonBackground.leadingAnchor),
            buttonLine.trailingAnchor.constraint(equalTo: buttonBackground.trailingAnchor),
            buttonLine.bottomAnchor.constraint(equalTo: buttonBackground.topAnchor),
            buttonLine.heightAnchor.constraint(equalToConstant: 1)
        ])

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: buttonBackground.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonBackground.centerYAnchor, constant: -10),
            button.widthAnchor.constraint(equalToConstant: 343),
            button.heightAnchor.constraint(equalToConstant: 48)
        ])

        NSLayoutConstraint.activate([
            shopPageTableView.leadingAnchor.constraint(equalTo: buttonBackground.leadingAnchor),
            shopPageTableView.trailingAnchor.constraint(equalTo: buttonBackground.trailingAnchor),
            shopPageTableView.heightAnchor.constraint(equalToConstant: 450)
        ])
        shopPageViewTopConstraint = shopPageTableView.topAnchor.constraint(equalTo: buttonBackground.topAnchor) //hide
        shopPageViewBottomConstraint = shopPageTableView.bottomAnchor.constraint(equalTo: buttonBackground.topAnchor) //show
        shopPageViewTopConstraint.isActive = true
    }

    //MARK: jump-up shop page

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                return 100
            } else if indexPath.row == 1 {
                return 300
            }
        }
        return UITableView.automaticDimension
    }

    var currentSection : Int = 0
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShopPageTableViewCell", for: indexPath) as! ShopPageTableViewCell
        cell.selectionStyle = .none
        cell.configureForType(for: indexPath, data: hot!)

        cell.backImageTappedHandler = { [weak self] in
            self?.closeButtonTapped()
        }
        self.cell2 = cell
        return cell
    }

    @objc func buttonTapped(_ sender: UIButton) {
        //MARK: shop page is open, show the animation if user input sth
        if shopPageViewBottomConstraint.isActive {
            shopPageViewBottomConstraint.isActive = false
            shopPageViewTopConstraint.isActive = true
            if let text = cell2?.numberTextField.text, let number = Int(text), number >= 1{
                let statusAlert = StatusAlert()
                statusAlert.image = UIImage(systemName: "checkmark.circle")
                statusAlert.title = "Great!"
                statusAlert.message = "Add to cart!"
                statusAlert.canBePickedOrDismissed = true
                statusAlert.showInKeyWindow()
                saveCartItem(section: currentSection)
                fetchCartItems()
            }
        //MARK: show shop page
        } else {
            shopPageViewTopConstraint.isActive = false
            shopPageViewBottomConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if self.makeDarkView.isHidden == true {
                self.makeDarkView.isHidden = false
            } else {
                self.makeDarkView.isHidden = true
            }
        }
    }


    // MARK: Save item to core data
    func saveCartItem(section: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        if shopPageTableView.numberOfRows(inSection: section) > 1 {
            let secondCellIndexPath = IndexPath(row: 1, section: section)
            if let cell = shopPageTableView.cellForRow(at: secondCellIndexPath) as? ShopPageTableViewCell {
                let newItem = CartItem(context: context)
                newItem.name = cell.productName
                newItem.price = cell.productPrice
                newItem.imageURL = hot!.images[0]
                newItem.color = cell.colorSelectedName
                newItem.size = cell.sizeSelectedName
                newItem.number = cell.numberTextField.text
                newItem.colorName = cell.colorName
                newItem.stock = String(cell.colorSizeStock)
                newItem.id = cell.productId
            }
        }

        do {
            try context.save()
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
    //MARK: fetch items & update badge
    func fetchCartItems() {
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

    @objc func closeButtonTapped() {
        if shopPageViewBottomConstraint.isActive {
            shopPageViewBottomConstraint.isActive = false
            shopPageViewTopConstraint.isActive = true
        } else {
            shopPageViewTopConstraint.isActive = false
            shopPageViewBottomConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if self.makeDarkView.isHidden == true {
                self.makeDarkView.isHidden = false
            } else {
                self.makeDarkView.isHidden = true
            }
        }
    }

    func setupPageControl() {
        guard productIndexPath != nil else {
            return
        }
        let numberOfPages = hot!.images.count
        pageControl = UIPageControl()
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .black
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(_:)), for: .valueChanged)

        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -10),
            pageControl.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor)
        ])
    }

    @objc func pageControlValueChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        let indexPath = IndexPath(item: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension DetailPageVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return hot!.images.count
        }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell

        guard let product = hot,
              let imageUrlString = product.images[safe: indexPath.item] else {
            return cell
        }
        cell.imageView.kf.setImage(with: URL(string: imageUrlString))
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.width
        let currentPage = Int((collectionView.contentOffset.x + pageWidth / 2) / pageWidth)
        pageControl.currentPage = currentPage
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: PhotoCell
class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView

    override init(frame: CGRect) {
        imageView = UIImageView(frame: .zero)
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        setPhotoCellConstraints()
    }

    private func setPhotoCellConstraints(){
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard cleanedHex.count == 6 else {
            return nil
        }

        let scanner = Scanner(string: cleanedHex)
        var hexValue: UInt64 = 0
        if scanner.scanHexInt64(&hexValue) {
            let red = CGFloat((hexValue >> 16) & 0xFF) / 255.0
            let green = CGFloat((hexValue >> 8) & 0xFF) / 255.0
            let blue = CGFloat(hexValue & 0xFF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else {
            return nil
        }
    }
}
