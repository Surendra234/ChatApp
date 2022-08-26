//
//  SignInVC.swift
//  ChatApp
//
//  Created by Admin on 20/08/22.
//

import UIKit

extension LoginViewController {
    
    func checkLoginDetail() {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            if !email.isValidEmail() {
                showAlert(title: "Alert", message: "please enter valid email id")
            }
            else if !password.isValidPassword() {
                showAlert(title: "Alert", message: "please enter valid password")
            }
            else {
                // Navigation Home Screen
                print("email and password are in correct formate")
            }
        }
        else {
            showAlert(title: "Alert", message: "please add detail")
        }
    }
    
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
