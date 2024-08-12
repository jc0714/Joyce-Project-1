//
//  AfterCheckVC.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/10.
//

import UIKit

class AfterCheckVC: UIViewController {

    @IBOutlet weak var shopMoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        shopMoreButton.addTarget(self, action: #selector(shopMoreButtonTapped), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @objc func shopMoreButtonTapped() {
        performSegue(withIdentifier: "BackToHomePage", sender: self)
    }
}
