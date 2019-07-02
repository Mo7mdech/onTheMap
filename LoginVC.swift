//
//  LoginVC.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 18/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextFields: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
       usernameTextField.delegate = self
       passwordTextFields.delegate = self
       
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        
        guard let email = usernameTextField.text, !email.isEmpty else {
            activityIndicator.stopAnimating()
            //enableControllers(true)
            showInfo(withTitle: "Field required", withMessage: "Please fill in your email.")
            return
        }
        guard let password = passwordTextFields.text, !password.isEmpty else {
            activityIndicator.stopAnimating()
            showInfo(withTitle: "Field required", withMessage: "Please fill in your password.")
            return
        }
        authenticateUserInfo(username: email, password: password)
        
    }
    
    @IBAction func dontHaveAccountButtonPressed(_ sender: UIButton) {
        self.performUIUpdatesOnMain {
            let url = URL(string: "https://auth.udacity.com/sign-up")
            UIApplication.shared.open(url!, options: [:])
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
        return true
    }
    
    private func authenticateUserInfo(username: String, password: String){
        Udacity.logInUdacity(password: password, username: username) { (success, error) in
            if success {
                print(username)
                print(password)
                UserDefaults.standard.set(username, forKey: "username")
                UserDefaults.standard.set(password, forKey: "password")
                self.performUIUpdatesOnMain {
                    self.usernameTextField.text = ""
                    self.passwordTextFields.text = ""
                    self.performSegue(withIdentifier: "logInSegue", sender: nil)
                }
            } else {
                self.performUIUpdatesOnMain {
                    self.showInfo(withTitle: "Login falied", withMessage: error?.localizedDescription ?? "Unknown Error")
                }
            }
            self.performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}
