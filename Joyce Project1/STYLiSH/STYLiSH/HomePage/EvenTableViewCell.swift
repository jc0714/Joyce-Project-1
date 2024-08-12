//
//  evenTableViewCell.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/18.
//

import UIKit

class EvenTableViewCell: UITableViewCell {

    @IBOutlet weak var productImage_b_1 : UIImageView!
    @IBOutlet weak var productImage_b_2 : UIImageView!
    @IBOutlet weak var productImage_b_3 : UIImageView!
    @IBOutlet weak var productImage_b_4 : UIImageView!
    @IBOutlet weak var productLabel_b : UILabel!
    @IBOutlet weak var thicknessLabel_b : UILabel!

    func update(with data: Product){
        self.productLabel_b.text = data.title
        self.productLabel_b.font = UIFont.systemFont(ofSize: 18)

        let imageViews: [UIImageView] = [self.productImage_b_1, self.productImage_b_2, self.productImage_b_3, self.productImage_b_4]

        for (index, imageView) in imageViews.enumerated() {
            if index < data.images.count {
                let urlString = data.images[index]
                if let url = URL(string: urlString) {
                    imageView.kf.setImage(with: url)
                }
            }
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let thicknessString = NSAttributedString(string: data.description, attributes: [
            .paragraphStyle: paragraphStyle
        ])
        self.thicknessLabel_b.attributedText = thicknessString
    }
}
