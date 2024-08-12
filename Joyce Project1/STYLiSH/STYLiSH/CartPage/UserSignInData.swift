//
//  userSignInData.swift
//  STYLiSH
//
//  Created by J oyce on 2024/8/7.
//

import Foundation
import Alamofire

struct User: Codable {
    let id: Int
    let provider: String
    let name: String
    let email: String
    let picture: String
}

struct SignInResponseData: Codable {
    let accessToken: String
    let accessExpired: String
    let user: User
}

struct SignInResponse: Codable {
    let data: SignInResponseData
}

struct UserProfile: Codable {
    let provider: String
    let name: String
    let email: String
    let picture: String
}

struct UserProfileResponse: Codable {
    let data: UserProfile
}


struct CheckoutRequest: Codable {
    let prime: String
    let order: Order

    struct Order: Codable {
        let shipping: String
        let payment: String
        let subtotal: Int
        let freight: Int
        let total: Int
        let recipient: Recipient
        let list: [Product]

        struct Recipient: Codable {
            let name: String
            let phone: String
            let email: String
            let address: String
            let time: String
        }

        struct Product: Codable {
            let id: String
            let name: String
            let price: Int
            let color: Color
            let size: String
            let qty: Int

            struct Color: Codable {
                let code: String
                let name: String
            }
        }
    }
}

var profilePictureURL: String = ""

func signInWithFacebook(token: String) {
    let userDefault = UserDefaults()
    let signInURL = URL(string: "https://api.appworks-school.tw/api/1.0/user/signin")!
    var signInRequest = URLRequest(url: signInURL)
    signInRequest.httpMethod = "POST"
    signInRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let signInParameters: [String: Any] = [
        "provider": "facebook",
        "accessToken": token
    ]

    signInRequest.httpBody = try? JSONSerialization.data(withJSONObject: signInParameters)

    let task = URLSession.shared.dataTask(with: signInRequest) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("SignIn JSON Response: \(jsonString)")
                }

                let decodedResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
                let accessToken = decodedResponse.data.accessToken
                userDefault.setValue(accessToken, forKey: "accessToken")
                print(userDefault.value(forKey: "accessToken") as! String)

                let profileURL = URL(string: "https://api.appworks-school.tw/api/1.0/user/profile")!
                var profileRequest = URLRequest(url: profileURL)
                profileRequest.httpMethod = "GET"
                profileRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

                let profileTask = URLSession.shared.dataTask(with: profileRequest) { profileData, profileResponse, profileError in
                    guard let profileData = profileData, profileError == nil else {
                        print("Error: \(profileError?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    if let profileHttpResponse = profileResponse as? HTTPURLResponse, profileHttpResponse.statusCode == 200 {
                        do {
                            if let profileJsonString = String(data: profileData, encoding: .utf8) {
                                print("Profile JSON Response: \(profileJsonString)")
                            }

                            let userProfileResponse = try JSONDecoder().decode(UserProfileResponse.self, from: profileData)
                            let user = userProfileResponse.data
                            profilePictureURL = user.picture

                        } catch {
                            print("Failed to decode JSON response: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to get user profile")
                    }
                }
                profileTask.resume()

            } catch {
                print("Failed to decode JSON response: \(error.localizedDescription)")
            }
        } else {
            print("Failed to get STYLiSH Token")
        }
    }
    task.resume()
}


