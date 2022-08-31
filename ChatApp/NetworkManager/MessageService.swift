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
    private let userMessageRef = Database.database().reference().child("user-messages")
    
    
    // Mark : Observer Conversion Messages
    func observeMessageAdded(user: User,completion: @escaping (Message) -> (Void)) {
        
        guard let uid = Auth.auth().currentUser?.uid,
              let toId = user.id else { return}
       
        userMessageRef.child(uid).child(toId).observe(.childAdded, with: { (snapshot) in
          
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
    
    
    // Mark : Obser All Users Messages
    func observeUserMessage(completion: @escaping (Message) -> (Void)) {
        
        guard let uid = Auth.auth().currentUser?.uid else { return}

        userMessageRef.child(uid).observe(.childAdded, with: { userIdSnapshot in

            let userId = userIdSnapshot.key
    
            self.userMessageRef.child(uid).child(userId).observe(.childAdded, with: { messageIdSnapshot in

                let messageId = messageIdSnapshot.key
                let messageReference = Database.database().reference().child("messages").child(messageId)
                
                messageReference.observeSingleEvent(of: .value, with: { snapshot in
          
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let message = Message(dictionary: dictionary)
                        
                        completion(message)
                    }
                }, withCancel: nil)

            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    func cancelObservers() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        userMessageRef.child(uid).removeAllObservers()
    }
}
