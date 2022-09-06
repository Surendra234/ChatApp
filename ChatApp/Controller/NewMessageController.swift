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
    
    // MARK: - Properties
    
    var timer: Timer?
    var users = [User]()
    var messageController: MessageTableViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUser()
    }
    
    // MARK: - Selector
    
    @objc func handleCancle() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.removeSpiner()
        }
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
     
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancle", style: .plain, target: self, action: #selector(handleCancle))
        
        tableView.rowHeight = 80
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    }
    
    private func fetchUser() {
        let ref = Database.database().reference().child("users")
        showSpiner()
        ref.observe(.childAdded, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
                self.users.append(user)
                
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)}
        }, withCancel: nil)
    }
}

// MARK: -

extension NewMessageController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.username
        cell.detailTextLabel?.text = user.email
        
        guard let imageUrl = user.imageUrl else  { return cell}
        guard let url = URL(string: imageUrl) else { return cell}
        cell.profileImageView.sd_setImage(with: url)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewMessageController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        dismiss(animated: true) {
            self.messageController?.showChatControllerForUser(user: user)
        }
    }
}
