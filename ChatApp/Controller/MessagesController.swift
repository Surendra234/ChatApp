//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Admin on 21/08/22.
//

import UIKit
import Firebase

private let reuseIdentifire = "CellId"

class MessagesController: UIViewController {
    
    
    // Mark : Properties
    
    var tableView: UITableView!
    
    var message = [Message]()
    var messageDictionary = [String: Message]()
    
    
    // Mark : init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemMint
        
        setUpNavBarItems()
        fetchUserAndSetupNavBarTitle()
        configureTableView()
    
        observeMessages()
    }
    
    
    // Mark : Handler
    
    func observeMessages() {
        
        let ref = Database.database().reference().child("message")
        
        ref.observe(.childAdded, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                //self.message.append(message)
                
                if let toId = message.toId {
                    self.messageDictionary[toId] = message
                    self.message = Array(self.messageDictionary.values)
                    
                    self.message.sort { message1, message2 in
                        return message1.timeStamp!.int32Value > message2.timeStamp!.int32Value
                    }
                }
                DispatchQueue.main.async { self.tableView.reloadData()}
            }
        }, withCancel: nil)
    }
    
    
    func setUpNavBarItems() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutButtonDidTapped))
        navigationItem.leftBarButtonItem?.tintColor = .black
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "message"), style: .plain, target: self, action: #selector(handleNewMessage))
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
    
    
    // Chat Contect
    @objc func handleNewMessage() {
    
        let newMessageController = NewMessageController()
        newMessageController.messageController = self
        navigationController?.pushViewController(newMessageController, animated: true)
    }
    
    
    // Mark:  get user
    func fetchUserAndSetupNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return}
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                self.setUpNavBarWithUser(user)
            }
        }
    }
    
    
    // set username or image
    func setUpNavBarWithUser(_ user: User) {
        
        let button = UIButton(type: .system)
        button.setTitle(user.username, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 18)
        button.tintColor = .black
        
        self.navigationItem.titleView = button
    }
    
    // Mark: showChatController
    func showChatControllerForUser(user: User) {
        
        let chatLogVC = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogVC.user = user
        self.navigationController?.pushViewController(chatLogVC, animated: true)
    }
    
    // Mark : TableView
    func configureTableView() {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifire)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
}


extension MessagesController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return message.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifire) as! UserCell
    
        cell.message = message[indexPath.row]
        
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
