//
//  CartTableViewCell.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/1.
//
import UIKit

class CartTableViewCell: UITableViewCell, UITextFieldDelegate {
    var productName: String?
    var productPrice: String?
    var colorSelected: String?
    var sizeSelected: String?
    var quantity: Int?
    var stock: String?
    var productId: String?
    var colorName: String?

    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Image_Placeholder")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let productNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let deleteButton: UIButton = {
        let deleteButton = UIButton()
        deleteButton.setTitle("移除", for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        deleteButton.setTitleColor(.gray, for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        return deleteButton
    }()

    var onDeleteButtonTapped: (() -> Void)?
    var indexPath: IndexPath?
    @objc private func deleteButtonTapped() {
        onDeleteButtonTapped?()
    }

    let colorView: UIView = {
        let colorView = UIView()
        colorView.translatesAutoresizingMaskIntoConstraints = false
        colorView.backgroundColor = UIColor(hex: "ff0000")
        return colorView
    }()

    let lineView: UIView = {
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = UIColor(hex: "D9D9D9")
        return lineView
    }()

    let sizeLabel: UILabel = {
        let sizeLabel = UILabel()
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        return sizeLabel
    }()

    let productPriceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
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

    var onAddButtonTapped: ((Int) -> Void)?
    @objc func addButtonTapped(_ sender: UIButton) {
        if let currentValue = Int(numberTextField.text ?? "0") {
            let newValue = currentValue + 1
            if newValue >= 1 && newValue <= Int(stock ?? "") ?? 0{
                numberTextField.text = "\(newValue)"
                onAddButtonTapped?(newValue)
            }
        }
    }

    var onSubtractButtonTapped: ((Int) -> Void)?
    @objc func subtractButtonTapped(_ sender: UIButton) {
        if let currentValue = Int(numberTextField.text ?? "0") {
            let newValue = currentValue - 1
            if newValue >= 1 && newValue <= Int(stock ?? "") ?? 0{
                numberTextField.text = "\(newValue)"
                onSubtractButtonTapped?(newValue)
            }
        }
    }

    let numberTextField: UITextField = {
        let textField = UITextField()
        textField.textAlignment = .center
        textField.textColor = UIColor(hex: "#3F3A3A")
        textField.layer.borderColor = UIColor(hex: "#3F3A3A")?.cgColor
        textField.layer.borderWidth = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .numberPad
        textField.text = "1"
        textField.isUserInteractionEnabled = true
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        numberTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: numberTextField)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(productImageView)
        contentView.addSubview(productNameLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(productPriceLabel)
        contentView.addSubview(colorView)
        contentView.addSubview(lineView)
        contentView.addSubview(sizeLabel)
        contentView.addSubview(addButton)
        contentView.addSubview(subtractButton)
        contentView.addSubview(numberTextField)
        numberTextField.delegate = self

        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            productImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            productImageView.widthAnchor.constraint(equalToConstant: 82),
            productImageView.heightAnchor.constraint(equalToConstant: 110),

            productNameLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            productNameLabel.topAnchor.constraint(equalTo: productImageView.topAnchor),

            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.topAnchor.constraint(equalTo: productImageView.topAnchor),

            colorView.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            colorView.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 10),
            colorView.heightAnchor.constraint(equalToConstant: 22),
            colorView.widthAnchor.constraint(equalToConstant: 22),

            lineView.leadingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: 10),
            lineView.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 12),
            lineView.heightAnchor.constraint(equalToConstant: 18),
            lineView.widthAnchor.constraint(equalToConstant: 2),

            sizeLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 10),
            sizeLabel.topAnchor.constraint(equalTo: productNameLabel.bottomAnchor, constant: 10),
            sizeLabel.heightAnchor.constraint(equalToConstant: 22),
            sizeLabel.widthAnchor.constraint(equalToConstant: 22),

            productPriceLabel.topAnchor.constraint(equalTo: sizeLabel.topAnchor),
            productPriceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            subtractButton.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 10),
            subtractButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 15),
            subtractButton.heightAnchor.constraint(equalToConstant: 32),
            subtractButton.widthAnchor.constraint(equalToConstant: 32),

            addButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 15),
            addButton.heightAnchor.constraint(equalToConstant: 32),
            addButton.widthAnchor.constraint(equalToConstant: 32),

            numberTextField.leadingAnchor.constraint(equalTo: subtractButton.trailingAnchor, constant: 0),
            numberTextField.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: 0),
            numberTextField.bottomAnchor.constraint(equalTo: subtractButton.bottomAnchor),
            numberTextField.widthAnchor.constraint(equalToConstant: 86),
            numberTextField.heightAnchor.constraint(equalToConstant: 32)

        ])
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        subtractButton.addTarget(self, action: #selector(subtractButtonTapped(_:)), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }

    // MARK: textField input
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        if let value = Int(currentText), value >= 1 {
            return true
        } else if currentText.isEmpty {
            return true
        }
        return false
    }

    @objc func textFieldDidChange(notification: Notification) {
        if let textField = notification.object as? UITextField {
            if let text = textField.text, let value = Int(text), value < 1 {
                textField.text = ""
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
