//
//  OddTableViewCell.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/17.
//

import UIKit

class OddTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage : UIImageView!
    @IBOutlet weak var productLabel : UILabel!
    @IBOutlet weak var thicknessLabel : UILabel!

    func update(with data: Product){
        self.productLabel.text = data.title
        self.productLabel.font = UIFont.systemFont(ofSize: 18)

        let urlString = data.mainImage
        let url = URL(string: urlString)
        self.productImage.kf.setImage(with: url)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let thicknessString = NSAttributedString(string: data.description, attributes: [
            .paragraphStyle: paragraphStyle
        ])
        self.thicknessLabel.attributedText = thicknessString
    }

}
