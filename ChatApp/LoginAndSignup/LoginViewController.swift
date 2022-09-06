//
//  SignInVC.swift
//  ChatApp
//
//  Created by Admin on 20/08/22.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func loginButtonDidTapped(_ sender: UIButton) {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        checkLoginDetail()
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, err) in
            
            if err != nil {
                self.showAlert(title: "Login Error", message: "User detail not found")
                return
            }
            
            let vc = MessageTableViewController()
            let scene = UIApplication.shared.connectedScenes.first
            
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                let chatVC = UINavigationController.init(rootViewController: vc)
                sd.window!.rootViewController = chatVC
            }
        }
    }
}
