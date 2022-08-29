//
//  Message.swift
//  ChatApp
//
//  Created by Admin on 25/08/22.
//

import UIKit
import Firebase

class Message {
    
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    
    
    init(dictionary: [String: Any]) {
        
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timeStamp = dictionary["timeStamp"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
}
