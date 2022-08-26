//
//  ForgotPasswordVC.swift
//  ChatApp
//
//  Created by Admin on 20/08/22.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
 
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func dismissAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func resetPasswordBtnClick(_ sender: UIButton) {
        
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!, completion: { (error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    self.showAlert(title: "Reset Failed", message: "Network busy")
                }
                else {
                    self.showAlert(title: "Email sent successfully", message: "click on the forget password link and change your password")
                }
            }
        })
    }
}


extension ForgotPasswordViewController {
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
