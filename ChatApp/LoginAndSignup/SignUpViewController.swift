//
//  SingUpViewController.swift
//  ChatApp
//
//  Created by Admin on 20/08/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    
    // Mark : Properties
    
    @IBOutlet weak var profileImageTap: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // Mark : Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupAvtar()
    }
    
    @IBAction func alreadyHaveAccount(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    
    // Mark : Handler
    
    @IBAction func signUpButtonDidTapped(_ sender: UIButton) {
        
        guard let profileImg = profileImageTap.image else { return }
        
        if let username = usernameTextField.text, let email = emailTextField.text, let password = passwordTextField.text {
            
            if !username.isValidUsername() {
                showAlert(title: "Invalid Username", message: "please enter a valid username")
            }
            
            else if !email.isValidEmail() {
                showAlert(title: "Invalid Email", message: "please enter a valid email")
            }
            
            else if !password.isValidPassword() {
                showAlert(title: "Invalid password", message: "please enter a valid password")
            }
            
            else {
                UserService.shared.ragistorUserInformation(username: username, email: email, password: password, image: profileImg) { isSuccess in
                    
                    if !isSuccess {
                        self.showAlert(title: "Busy Network", message: "There is some issue in user registration please try again")
                    }
                    else {
                        self.dismiss(animated: true)
                    }
                }
            }
        }
    }
}
