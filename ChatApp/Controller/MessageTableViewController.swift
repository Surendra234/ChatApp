//
//  MessageControllerTableView.swift
//  ChatApp
//
//  Created by Admin on 27/08/22.
//

import UIKit
import Firebase

private let cellId = "cellId"

class MessageTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    var timer: Timer?
    var logOutButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        checkIfUserIsLoggedIn()
    }
    
    // MARK: - Selector
    
    @objc func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort { message1, message2 in
            return message1.timeStamp!.int32Value > message2.timeStamp!.int32Value }
        
        DispatchQueue.main.async { self.tableView.reloadData()}
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        let nav = UINavigationController(rootViewController: newMessageController)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc func logOutButtonDidTapped() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constant.StoryboardKeys.LoginViewController)}
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: - Helpers
    
    private func observeUserMessages() {
        MessageService.shared.observeUserMessage { message in
            
            if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
            }
            self.attemptReloadOfTable()
        }
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    private func configureUI() {
        configureNavigationBar(withTitle: "")
        setupNavBarItem()
        tableView.rowHeight = 80
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.allowsMultipleSelectionDuringEditing = true
    }
    
    private func setupNavBarItem() {
        
        logOutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutButtonDidTapped))
        logOutButton?.tintColor = .tintColor
        navigationItem.leftBarButtonItem = logOutButton
        
        let image = UIImage(systemName: "bubble.left")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    }
    
    private func setupNavBarWithUser(_ user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        guard let navBarTitle = user.username else { return}
        self.navigationItem.backButtonTitle = "back"
        self.configureNavigationBar(withTitle: navBarTitle)
    }
    
    private func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }
    }
    
    private func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logOutButtonDidTapped), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        navigationController?.pushViewController(chatLogVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MessageTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let message = self.messages[indexPath.row]
        deleteConversation(withUser: message)
    }
}

// MARK: - UITableViewDelegate

extension MessageTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return}
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return}
            
            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
}

// MARK: - DeleteConversation

extension MessageTableViewController {
    
    private func deleteConversation(withUser message: Message) {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { err, ref in
                
                if err != nil {
                    print(err?.localizedDescription as Any)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadOfTable()
            }
        }
    }
}
