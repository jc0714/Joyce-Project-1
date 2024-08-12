//
//  UserViewController.swift
//  STYLiSH
//
//  Created by J oyce on 2024/7/22.
//
import UIKit
import FacebookLogin
import Kingfisher

class UserViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var userPageCollectionView: UICollectionView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPageCollectionView.dataSource = self
        userPageCollectionView.delegate = self
        setupCollectionView()

        if let token = AccessToken.current, !token.isExpired {
            // User is logged in, do work such as go to next view controller.
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Profile.loadCurrentProfile { profile, error in
            if let firstName = profile?.firstName {
                self.userName.text = firstName
            }
        }
        let imageURL = URL(string: profilePictureURL)
        self.userImage.kf.setImage(with: imageURL)
    }

    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        userPageCollectionView.collectionViewLayout = layout
    }
    
    let orderImage = ["Icons_24px_AwaitingPayment","Icons_24px_AwaitingShipment","Icons_24px_Shipped","Icons_24px_AwaitingReview","Icons_24px_Exchange"]

    let orderLabel = ["待付款","待出貨","待簽收","待評價","退換貨"]

    let moreServiceImage = ["Icons_24px_Starred","Icons_24px_Notification","Icons_24px_Refunded","Icons_24px_Address","Icons_24px_CustomerService","Icons_24px_SystemFeedback","Icons_24px_RegisterCellphone","Icons_24px_Settings"]

    let moreServiceLabel = ["收藏","貨到通知","帳戶退款","地址","客服訊息","系統回饋","手機綁定","設定"]
    
    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return orderImage.count
        case 1:
            return moreServiceImage.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = userPageCollectionView.dequeueReusableCell(withReuseIdentifier: "PersonCollectionViewCell", for: indexPath) as! UserCollectionViewCell
        if indexPath.section == 0{
            let imageName = orderImage[indexPath.item]
            cell.userPageImage.image = UIImage(named: imageName)
            cell.userPageLabel.text = orderLabel[indexPath.item]
        } else {
            let imageName = moreServiceImage[indexPath.item]
            cell.userPageImage.image = UIImage(named: imageName)
            cell.userPageLabel.text = moreServiceLabel[indexPath.item]
        }
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return calculateInteritemSpacing(for: section)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return calculateInteritemSpacing(for: section)
    }

    private func calculateInteritemSpacing(for section: Int) -> CGFloat {
        let numberOfItemsInRow: CGFloat = section == 0 ? 5 : 4
        let cellWidth: CGFloat = 60
        let screenWidth = userPageCollectionView.bounds.width
        let totalCellWidth = numberOfItemsInRow * cellWidth
        let totalSpacing = screenWidth - totalCellWidth - 32
        return totalSpacing / (numberOfItemsInRow)
    }

    // MARK: Header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView", for: indexPath) as! headerView
        headerView.headerView.text = indexPath.section == 0 ? "我的訂單" : "更多服務"

        headerView.headerLookMore.text = indexPath.section == 0 ? "查看更多>" :""
        headerView.headerLookMore.textColor = .gray
        return headerView
    }
}
