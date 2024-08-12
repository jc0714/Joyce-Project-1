//
//  HomeShopPageTableViewCell.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/29.
//

// 加入購物車的頁面
import UIKit

class ShopPageTableViewCell: UITableViewCell, UITextFieldDelegate {
    var data : Product?

    var colorSelected: Int = -1
    var colorSelectBorders: [UIView] = []
    var colorViews: [UIButton] = []
    var colorIsTapped = false
    var colorSelectedName: String = ""
    var colorName: String = ""

    var productName: String = ""
    var sizeSelectedName: String = ""
    var productPrice: String = ""
    var sizeSelected: Int = -1
    var colorSizeStock: Int = -1
    var productId: String = ""
    
    let productNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor(hex: "#3F3A3A")
        label.numberOfLines = 0
        return label
    }()

    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: "#3F3A3A")
        label.font = UIFont.systemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()

    let divideLineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(hex: "#CCCCCC")
        return view
    }()

    let colorTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#646464")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let sizeTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#646464")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let numberTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#646464")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let subtractButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Icons_24px_Subtract01"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Icons_24px_Add01"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let numberTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.textColor = UIColor(hex: "#3F3A3A")
        textField.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        textField.layer.borderWidth = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        return textField
    }()

    let stockNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(hex: "#646464")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var backImageTappedHandler: (() -> Void)?
    @objc private func handleBackImageTapped() {
        backImageTappedHandler?()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func colorViewTapped(_ sender: UIButton) {
        numberTextField.text = ""
        for border in colorSelectBorders {
            border.isHidden = true
        }

        if let index = colorViews.firstIndex(of: sender) {
            colorSelectedName = (data?.colors[sender.tag].code)!
            colorName = (data?.colors[sender.tag].name)!
            productId = String(data?.id ?? 0)
            stockNumberLabel.isHidden = true
            colorSelectBorders[index].isHidden = false
            colorSelected = sender.tag
            colorIsTapped = true
            enableSizeButtons()
        }
        for border in sizeSelectBorders {
            border.isHidden = true
        }
    }
    
    var sizeSelectBorders: [UIView] = []
    var sizeViews: [UIButton] = []

    @objc func sizeViewTapped(_ sender: UIButton) {
        addButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        subtractButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        numberTextField.isUserInteractionEnabled = true
        numberTextField.text = "1"
        stockNumberLabel.isHidden = false

        for border in sizeSelectBorders {
            border.isHidden = true
        }
        if let index = sizeViews.firstIndex(of: sender) {
            sizeSelectedName = (data?.sizes[sender.tag])!
            productName = (data?.title)!
            productPrice = String((data?.price)!)
            sizeSelectBorders[index].isHidden = false
            sizeSelected = sender.tag
        }
        for i in 0..<data!.variants.count{
            if data?.variants[i].colorCode == colorSelectedName && data?.variants[i].size == sizeSelectedName{
                colorSizeStock = data?.variants[i].stock ?? 0
                stockNumberLabel.text = "庫存:\(colorSizeStock) "
                stockNumberLabel.isHidden = false
            }
        }
    }

    func enableSizeButtons() {
        for i in 0..<(data?.variants.count ?? 0){
            if data?.variants[i].colorCode == colorSelectedName{
                let index = i % (data?.sizes.count ?? 1)
                if data?.variants[i].stock != 0 {
                    sizeViews[index].isUserInteractionEnabled = true
                    sizeViews[index].backgroundColor = UIColor(hex: "#F0F0F0")
                } else {
                    sizeViews[index].isUserInteractionEnabled = false
                    sizeViews[index].backgroundColor = .gray
                }
            }
        }
    }

    @objc func addButtonTapped(_ sender: UIButton) {
        if let currentValue = Int(numberTextField.text ?? "0") {
            let newValue = currentValue + 1
            if newValue > 1 && newValue < colorSizeStock{
                numberTextField.text = "\(newValue)"
                addButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
                subtractButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
            } else {
                if newValue == 1 {
                    let newValue = 1
                    numberTextField.text = "\(newValue)"
                    subtractButton.layer.borderColor = UIColor(hex: "#b8b1b0")?.cgColor
                } else if newValue == colorSizeStock {
                    let newValue = colorSizeStock
                    numberTextField.text = "\(newValue)"
                    addButton.layer.borderColor = UIColor(hex: "#b8b1b0")?.cgColor
                }
            }
        }
    }

    @objc func subtractButtonTapped(_ sender: UIButton) {
        if let currentValue = Int(numberTextField.text ?? "0") {
            let newValue = currentValue - 1
            if newValue > 1 && newValue < colorSizeStock{
                numberTextField.text = "\(newValue)"
                addButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
                subtractButton.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
            } else {
                if newValue == 1 {
                    let newValue = 1
                    numberTextField.text = "\(newValue)"
                    subtractButton.layer.borderColor = UIColor(hex: "#b8b1b0")?.cgColor
                } else if newValue == colorSizeStock {
                    let newValue = colorSizeStock
                    numberTextField.text = "\(newValue)"
                    addButton.layer.borderColor = UIColor(hex: "#b8b1b0")?.cgColor
                }
            }
        }
    }

    func configureForType(for indexPath: IndexPath, data: Product) {

        guard UIApplication.shared.delegate is AppDelegate else { return }

        self.data = data
        productNameLabel.isHidden = true
        productPriceLabel.isHidden = true
        divideLineView.isHidden = true
        colorTitleLabel.isHidden = true
        sizeTitleLabel.isHidden = true
        numberTitleLabel.isHidden = true
        subtractButton.isHidden = true
        numberTextField.isHidden = true
        addButton.isHidden = true
        stockNumberLabel.isHidden = true
        closeButton.isHidden = true

        switch indexPath.row {
        case 0:
            
            productNameLabel.isHidden = false
            productPriceLabel.isHidden = false
            divideLineView.isHidden = false
            closeButton.isHidden = false
            productNameLabel.text = data.title
            productPriceLabel.text = "NT $ \(data.price)"
            
        case 1:

            colorTitleLabel.isHidden = false
            colorTitleLabel.text = "選擇顏色"
            var distance = 16
            for i in 0..<data.colors.count {
                let colorView = UIButton()
                let colorSelectborder = UIView()
                colorSelectborder.backgroundColor = .clear
                colorSelectborder.layer.borderWidth = 1
                colorSelectborder.layer.borderColor = UIColor.black.cgColor
                colorSelectborder.translatesAutoresizingMaskIntoConstraints = false
                colorView.translatesAutoresizingMaskIntoConstraints = false
                colorView.backgroundColor = UIColor(hex: data.colors[i].code)

                colorView.tag = i // Set the tag here

                contentView.addSubview(colorView)
                contentView.addSubview(colorSelectborder)
                colorSelectBorders.append(colorSelectborder)
                colorViews.append(colorView)

                NSLayoutConstraint.activate([
                    colorView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 12),
                    colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(distance)),
                    colorView.heightAnchor.constraint(equalToConstant: 48),
                    colorView.widthAnchor.constraint(equalToConstant: 48),
                ])

                NSLayoutConstraint.activate([
                    colorSelectborder.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 9),
                    colorSelectborder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(distance - 3)),
                    colorSelectborder.heightAnchor.constraint(equalToConstant: 54),
                    colorSelectborder.widthAnchor.constraint(equalToConstant: 54),
                ])

                colorView.addTarget(self, action: #selector(colorViewTapped(_:)), for: .touchUpInside)

                distance += 64
                colorSelectborder.isHidden = true
            }

            sizeTitleLabel.isHidden = false
            sizeTitleLabel.text = "選擇尺寸"
            var distanceCase2 = 16
            
            for i in 0..<data.sizes.count {
                let sizeView = UIButton()
                let selectborder = UIView()
                selectborder.backgroundColor = .clear
                selectborder.layer.borderWidth = 1
                selectborder.layer.borderColor = UIColor.black.cgColor
                selectborder.translatesAutoresizingMaskIntoConstraints = false
                sizeView.translatesAutoresizingMaskIntoConstraints = false
                sizeView.setTitle(String(data.sizes[i]), for: .normal)
                sizeView.setTitleColor(UIColor(hex: "#3F3A3A"), for: .normal)
                sizeView.titleLabel?.font = UIFont.systemFont(ofSize: 16)
                sizeView.titleLabel?.textAlignment = .center
                sizeView.backgroundColor = UIColor(hex: "#F0F0F0")
                sizeView.isUserInteractionEnabled = false

                sizeView.tag = i

                contentView.addSubview(sizeView)
                contentView.addSubview(selectborder)

                sizeSelectBorders.append(selectborder)
                sizeViews.append(sizeView)

                NSLayoutConstraint.activate([
                    sizeView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(distanceCase2)),
                    sizeView.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 12),
                    sizeView.heightAnchor.constraint(equalToConstant: 48),
                    sizeView.widthAnchor.constraint(equalToConstant: 48),
                ])

                NSLayoutConstraint.activate([
                    selectborder.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 9),
                    selectborder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: CGFloat(distanceCase2)-3),
                    selectborder.heightAnchor.constraint(equalToConstant: 54),
                    selectborder.widthAnchor.constraint(equalToConstant: 54),
                ])

                sizeView.addTarget(self, action: #selector(sizeViewTapped(_:)), for: .touchUpInside)

                distanceCase2 += 64
                selectborder.isHidden = true
            }

            numberTitleLabel.isHidden = false
            numberTitleLabel.text = "選擇數量"
            subtractButton.isHidden = false
            numberTextField.isHidden = false
            addButton.isHidden = false
            numberTextField.delegate = self
            numberTextField.isUserInteractionEnabled = false


            subtractButton.addTarget(self, action: #selector(subtractButtonTapped(_:)), for: .touchUpInside)
            addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)

            NotificationCenter.default.addObserver(self, selector: #selector(handlePaste(notification:)), name: UITextField.textDidChangeNotification, object: numberTextField)
        default:
            break
        }
    }

    private func setupViews() {
        [productNameLabel, productPriceLabel, divideLineView, colorTitleLabel, sizeTitleLabel, numberTitleLabel, subtractButton, addButton, numberTextField, stockNumberLabel, closeButton].forEach { contentView.addSubview($0) }
        closeButton.addTarget(self, action: #selector(handleBackImageTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            productNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            closeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            productNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            productPriceLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 0),
            productPriceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            productPriceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),


            closeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),

            divideLineView.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            divideLineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divideLineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            divideLineView.heightAnchor.constraint(equalToConstant: 1),

            colorTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            sizeTitleLabel.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 75),
            sizeTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            numberTitleLabel.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 75),
            numberTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            subtractButton.topAnchor.constraint(equalTo: numberTitleLabel.bottomAnchor, constant: 12),
            subtractButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtractButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            subtractButton.heightAnchor.constraint(equalToConstant: 48),
            subtractButton.widthAnchor.constraint(equalToConstant: 48),

            addButton.topAnchor.constraint(equalTo: numberTitleLabel.bottomAnchor, constant: 12),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            addButton.heightAnchor.constraint(equalToConstant: 48),
            addButton.widthAnchor.constraint(equalToConstant: 48),

            numberTextField.topAnchor.constraint(equalTo: numberTitleLabel.bottomAnchor, constant: 12),
            numberTextField.leadingAnchor.constraint(equalTo: subtractButton.trailingAnchor, constant: 0),
            numberTextField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: 0),
            numberTextField.bottomAnchor.constraint(equalTo: subtractButton.bottomAnchor),

            stockNumberLabel.topAnchor.constraint(equalTo: sizeTitleLabel.bottomAnchor, constant: 75),
            stockNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: only accept numbers input
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        numberTextField.text = ""
        if let numericValue = Int(newText){
            if numericValue > 0 && numericValue <= colorSizeStock{
                return true
            }
        }
        return false
    }
    
    // MARK: only accecpt num paste
    @objc func handlePaste(notification: Notification) {
        if let textField = notification.object as? UITextField, textField.keyboardType == .numberPad {
            if let pastedText = textField.text {
                let numericText = pastedText.trimmingCharacters(in: CharacterSet.decimalDigits.inverted)
                if let numericValue = Int(numericText) {
                    if numericValue >= 0 && numericValue <= colorSizeStock {
                        textField.text = numericText
                    } else {
                        print("Pasted value exceeds stock limit.")
                    }
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
