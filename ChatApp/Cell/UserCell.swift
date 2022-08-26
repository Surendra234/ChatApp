//
//  UserCell.swift
//  ChatApp
//
//  Created by Admin on 24/08/22.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {

    
    var message: Message? {
        didSet {
            if let toId = message?.toId {
                let ref = Database.database().reference().child("users").child(toId)
                
                ref.observeSingleEvent(of: .value, with: { snapshot in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        
                        self.textLabel?.text = dictionary["username"] as? String
                        
                        if let imageUrl = dictionary["imageUrl"] as? String {
                            
                            guard let url = URL(string: imageUrl) else { return}
                            guard let data = try? Data(contentsOf: url) else { return}
                            
                            self.profileImageView.image = UIImage(data: data)}
                    }
                    
                }, withCancel: nil)
            }
            detailTextLabel?.text = message?.text
            
            if let second = message?.timeStamp?.doubleValue {
                let timeStamDate = Date(timeIntervalSince1970: second)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                
                timeLabe.text = dateFormatter.string(from: timeStamDate)
            }
        }
    }
    
    
    
    let profileImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabe: UILabel = {
       
        let label = UILabel()
        label.text = "HH:MM"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabe)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        timeLabe.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabe.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabe.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabe.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
