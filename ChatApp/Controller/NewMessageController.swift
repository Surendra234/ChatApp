//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Admin on 24/08/22.
//

import UIKit
import Firebase

private let cellId = "cellId"

class NewMessageController: UITableViewController {
    
    
    // Mark : Properties
    
    var users = [User]()
    
    var messageController: MessagesController?
    
    
    // Mark : init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancle", style: .plain, target: self, action: #selector(handleCancle))
        
        self.navigationItem.hidesBackButton = true
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    
    
    // Mark : Handler
    
    @objc func handleCancle() {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true)
    }
    
    
    func fetchUser() {
        
        Database.database().reference().child("users").observe(.childAdded, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User(dictionary: dictionary)
    
                user.id = snapshot.key
                self.users.append(user)
        
                DispatchQueue.main.async { self.tableView.reloadData()}
            }
        }, withCancel: nil)
    }
    
    
    // Mark : TableView methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]

        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        
        if let url = URL(string: user.imageUrl!) {

            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data: data)}
            }
        }
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        self.messageController?.showChatControllerForUser(user: user)
    }
}
