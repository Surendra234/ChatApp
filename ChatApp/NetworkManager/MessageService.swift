//
//  MessageService.swift
//  ChatApp
//
//  Created by Admin on 27/08/22.
//

import Firebase
import UIKit

class MessageService {
    
    static let shared = MessageService()
    private let ref = Database.database().reference().child("user-messages")
    
    func observeMessageAdded(completion: @escaping (Message) -> (Void)) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
       
        ref.child(uid).observe(.childAdded, with: { (snapshot) in
          
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)

            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)
                    completion(message)
                }
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func cancelObservers() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        ref.child(uid).removeAllObservers()
    }
}
