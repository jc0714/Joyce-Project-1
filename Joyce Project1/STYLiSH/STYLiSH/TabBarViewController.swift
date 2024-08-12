//
//  TabBarViewController.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/7.
//

import UIKit
import FacebookLogin
import StatusAlert

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    var previousIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
            if index == 2 || index == 3 {
                if AccessToken.current == nil {
                    print("User is not logged in")

                    setFBButton()

                    return false
                }
            }
        }
        return true
    }


    func setFBButton() {
        let btnView = UIView()
        let screenHeight = self.view.frame.size.height
        let screenWidth = self.view.frame.size.width

        btnView.frame = CGRect(x: 0, y: screenHeight * 3/4, width: screenWidth, height: 220)
        btnView.backgroundColor = .white
        btnView.layer.borderColor = UIColor.black.cgColor
        btnView.layer.borderWidth = 0.5
        btnView.layer.cornerRadius = 15.0
        btnView.layer.masksToBounds = true

        let makeDarkView = UIView()
        makeDarkView.backgroundColor = .black
        makeDarkView.alpha = 0.5
        makeDarkView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        makeDarkView.tag = 999
        self.view.addSubview(makeDarkView)

        let titleLabel = UILabel()
        titleLabel.text = "請先登入會員"
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.frame = CGRect(x: 20, y: 24, width: screenWidth, height: 30)
        btnView.addSubview(titleLabel)

        let textLabel = UILabel()
        textLabel.text = "登入會員後即可完成結帳。"
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        textLabel.frame = CGRect(x: 20, y: 73, width: screenWidth, height: 30)
        btnView.addSubview(textLabel)

        let lineView = UIView()
        lineView.backgroundColor = .gray
        lineView.frame = CGRect(x: 16, y: 118, width: 343, height: 1)
        btnView.addSubview(lineView)

        let loginButton = UIButton(type: .custom)
        loginButton.backgroundColor = UIColor(red: 59/255, green: 89/255, blue: 152/255, alpha: 1.0)
        loginButton.frame = CGRect(x: 50, y: 135, width: 300, height: 50)
        loginButton.setTitle("Facebook 登入", for: .normal)
        loginButton.addTarget(self, action: #selector(loginButtonClicked), for: .touchUpInside)
        btnView.addSubview(loginButton)

        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "Icons_24px_Close"), for: .normal)
        closeButton.frame = CGRect(x: btnView.frame.width - 24 - 15, y: 15, width: 24, height: 24)
        closeButton.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        btnView.addSubview(closeButton)

        self.view.addSubview(btnView)
    }

    @objc func closeView(sender: UIButton) {
        self.view.subviews.filter { $0.tag == 999 || $0 == sender.superview }.forEach { $0.removeFromSuperview() }
    }

    @objc func loginButtonClicked(sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile"], from: self) { result, error in
            if let error = error {
                print("Encountered Erorr: \(error)")
            } else if let result = result, let tokenString = result.token?.tokenString {
                print("Logged in with token: \(tokenString)")
                signInWithFacebook(token:tokenString)

                let statusAlert = StatusAlert()
                statusAlert.image = UIImage(systemName: "checkmark.circle")
                statusAlert.title = "Log in successful!"
                statusAlert.canBePickedOrDismissed = true
                statusAlert.showInKeyWindow()

                self.view.subviews.filter { $0.tag == 999 || $0 == sender.superview }.forEach { $0.removeFromSuperview() }
            }
        }
    }

}
