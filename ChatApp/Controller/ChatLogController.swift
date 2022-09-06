//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Admin on 25/08/22.
//

import UIKit
import Firebase

private let cellId = "cellId"

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            navigationItem.title = user?.username
            observerMessage()
        }
    }
    
    var messages = [Message]()
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var containerViewBottomAnchor: NSLayoutConstraint?

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
    
    let uploadImageView: UIImageView = {
        
        let iv = UIImageView()
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(systemName: "photo.artframe")
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        initializeHideKeyboard()
        setupInputComponents()
        setupKeyboardObservers()
    }
    
    // MARK: - Selector
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 68, right: 0)
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        
        containerViewBottomAnchor?.constant = 0
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleUploadTap() {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc func handleSend() {
        
        guard let text = inputTextField.text else { return}
        let properties = ["text": text]
        
        sendMessageWithProperties(properties as [String: AnyObject])
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            } completion: { completed in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            }
        }
    }
    
    // MARK: - Helpers
    
    func setupKeyboardObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func observerMessage() {
        guard let user = user else { return}
        MessageService.shared.observeMessageAdded(user: user) { message in
            
            self.messages.append(message)
            self.collectionView.reloadData()
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
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
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        containerView.addSubview(uploadImageView)
        [
            uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            uploadImageView.widthAnchor.constraint(equalToConstant: 40),
            uploadImageView.heightAnchor.constraint(equalToConstant: 40)
        ].forEach { $0.isActive = true}
        
        containerView.addSubview(inputTextField)
        [
            inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8),
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
        
        if let messageImageUrl = message.imageUrl {
        
            guard let url = URL(string: messageImageUrl) else { return}
            cell.messageImageView.sd_setImage(with: url)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        }
        else {
            cell.messageImageView.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
                
        if let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ChatLogController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        cell.chatLogController = self

        setupCell(cell: cell, message: message)
        if let text = message.text {
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text).width + 32
            cell.textView.isHidden = false
        }
        else if message.imageUrl != nil {
            cell.bubbleViewWidthAnchor?.constant = 200
            cell.textView.isHidden = true
            cell.messageImageView.sd_setShowActivityIndicatorView(false)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ChatLogController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        let width = UIScreen.main.bounds.width
        let message = messages[indexPath.item]
        
        if let text = message.text {
            height = estimateFrameForText(text).height + 20
        }
        else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: width, height: height)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            MessageService.shared.imageUploder(image: selectedImage) { imageUrl in
                self.sendMessageWithImageUrl(imageUrl, image: selectedImage)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    fileprivate func sendMessageWithImageUrl(_ imageUrl: String, image: UIImage) {
        
        let properties: [String: AnyObject] = ["imageUrl": imageUrl as AnyObject, "imageWidth": image.size.width as AnyObject, "imageHeight": image.size.height as AnyObject]
        
        sendMessageWithProperties(properties)
    }
    
    fileprivate func sendMessageWithProperties(_ properties: [String: AnyObject]) {

        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()

        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = Int(Date().timeIntervalSince1970)

        var values: [String: AnyObject] = ["toId": toId as AnyObject, "fromId": fromId as AnyObject, "timeStamp": timeStamp as AnyObject]

        properties.forEach({values[$0] = $1})

        childRef.updateChildValues(values) { err, ref in
            if err != nil {
                print("error")
                return
            }
            self.inputTextField.text = nil
            guard let messageId = childRef.key else { return}

            let userMessageRef = Database.database().reference().child("user-messages").child(fromId).child(toId).child(messageId)

            userMessageRef.setValue(1)

            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId).child(messageId)

            recipientUserMessageRef.setValue(1)
        }
    }
}
