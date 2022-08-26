//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Admin on 25/08/22.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    
    // Mark : Properties
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
        }
    }
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget((Any).self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        
        textField.placeholder = "enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    
    // Mark : Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupInputComponents()
    }
    
    
    // Mark : Handler
    
    func setupInputComponents() {
        
        let containerView = UIView()
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        
        [
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 60)
        ].forEach { $0.isActive = true}
        
        
        containerView.addSubview(sendButton)
        
        [
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ].forEach { $0.isActive = true}
        
        
        containerView.addSubview(inputTextField)
        
        [
            inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor),
            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ].forEach { $0.isActive = true}
        
        
        let separatorLineView = UIView()
        
        separatorLineView.backgroundColor = .black
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        [
            separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor),
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            separatorLineView.heightAnchor.constraint(equalToConstant: 1)
        ].forEach { $0.isActive = true}
        
    }
    
    @objc func handleSend() {
        
        let ref = Database.database().reference().child("message")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)
        
        let value = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        
        childRef.updateChildValues(value)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
