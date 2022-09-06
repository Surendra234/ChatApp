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
    
    // MARK: - UploadImage
    
    func imageUploder(image: UIImage, Compeltion: @escaping (String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return}
        let fileName = NSUUID().uuidString
        let refrance = Storage.storage().reference(withPath: "profile_image/\(fileName)")
        
        refrance.putData(imageData, metadata: nil) { metaData, error in
            
            if error != nil {
                print("Fail to uplode file \(String(describing: error?.localizedDescription))")
            }
            
            refrance.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return}
                Compeltion(imageUrl)
            }
        }
    }
    
    // MARK: ObserverMessages
    
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
    
    // MARK: - ObserverUserMessage

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
    
    // MARK: - FetchuserConversation
    
    func fetchuserConversation(withUser message: Message, completion: @escaping (_ dictionary: [String: AnyObject]) -> (Void)) {

        if let id = message.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)

            ref.observeSingleEvent(of: .value, with: { snapshot in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    completion(dictionary)
                }

            }, withCancel: nil)
        }
    }
    
    // MARK: - CancelObservers
    
    func cancelObservers() {
        guard let uid = Auth.auth().currentUser?.uid else { return}
        userMessageRef.child(uid).removeAllObservers()
    }
}

