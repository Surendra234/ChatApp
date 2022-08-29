//
//  User.swift
//  ChatApp
//
//  Created by Admin on 24/08/22.
//

import UIKit

class User {
    
    var id: String?
    var username: String?
    var email: String?
    var imageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        
        self.id = dictionary["id"] as? String
        self.username = dictionary["username"] as? String
        self.email = dictionary["email"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
    }
}
