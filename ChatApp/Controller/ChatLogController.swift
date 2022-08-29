//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Admin on 25/08/22.
//

import UIKit
import Firebase

private let cellId = "cellId"

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    

    // Mark : Properties
    var containerViewBottomAnchor: NSLayoutConstraint?
    var messages = [Message]()
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
            observerMessage()
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
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponents()
        setupKeyboardObservers()
    }

    // Mark : Keyboard
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // Mark : Handler
    @objc func handleKeyboardWillShow(notification: Notification) {
        
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func observerMessage() {
        
        MessageService.shared.observeMessageAdded { message in
            
            if message.chatPartnerId() == self.user?.id {
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()}
            }
        }
    }
    
    private func estimateFrameForText(_ text: String) -> CGRect {
        
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
        
    private func setupInputComponents() {
        
        let containerView = UIView()
        
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
        [
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor),
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
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)

        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timeStamp": timeStamp] as [String : Any]
        
        childRef.updateChildValues(values) { err, ref in
            if err != nil {
                print("error")
                return
            }
            self.inputTextField.text = nil
            guard let messageId = childRef.key else { return}
            
            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(messageId)
            
            userMessageRef.setValue(1)
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(messageId)
            
            recipientUserMessageRef.setValue(1)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
    
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor(red: 50/255, green: 120/255, blue: 250/255, alpha: 1)
            cell.textView.textColor = .white
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }
        else {
            cell.bubbleView.backgroundColor = .secondarySystemBackground
            cell.textView.textColor = .black
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    // Mark : CollectionView DataSource Methods
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
    
        // Steup bubble chat message
        setupCell(cell: cell, message: message)
        cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(message.text!).width + 32
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text).height + 20
        }
        return CGSize(width: view.frame.width, height: height)
    }
}
