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
    
    // Mark : Properties
    var timer: Timer?
    var logOutButton: UIBarButtonItem?
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    
    // Mark : init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBarItem()
        fetchUserAndSetupNavBarTitle()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    func setupNavBarItem() {
        
        self.navigationController?.navigationBar.backgroundColor = .secondarySystemBackground
        logOutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutButtonDidTapped))
        logOutButton?.tintColor = .tintColor
        navigationItem.leftBarButtonItem = logOutButton
        
        let image = UIImage(systemName: "bubble.left")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
    }
    
    func setupNavBarWithUser(_ user: User) {
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        observeUserMessages()
        
        let button = UIButton(type: .system)
        button.setTitle(user.username, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        button.tintColor = .black
        
        self.navigationItem.titleView = button
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        self.navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    // Mark: Handler
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // show list of user on a new message controller
    @objc func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        navigationController?.pushViewController(newMessageController, animated: true)
    }
    
    // Set username on top
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
            }
        }
    }
    
    func observeUserMessages() {
        
        MessageService.shared.observeMessageAdded { message in
            
            if let chatPartnerId = message.chatPartnerId() {
                self.messagesDictionary[chatPartnerId] = message
                self.messages = Array(self.messagesDictionary.values)

                self.messages.sort { message1, message2 in
                    return message1.timeStamp!.int32Value > message2.timeStamp!.int32Value
                }
            }
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        }
    }
    
    // Mark: TableView datasource methode
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
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
    
    // logout button
    @objc func logOutButtonDidTapped() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let scene = UIApplication.shared.connectedScenes.first
            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                sd.window?.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constant.StoryboardKeys.LoginViewController)
            }
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

