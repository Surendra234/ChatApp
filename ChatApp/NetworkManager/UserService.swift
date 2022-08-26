//
//  UserService.swift
//  ChatApp
//
//  Created by Admin on 21/08/22.
//

import Foundation
import Firebase
import FirebaseAuth

struct UserService {
    
    static let shared = UserService()
    
    // Mark : upload image
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
    
    // Mark : Set userinfo
    func ragistorUserInformation(username: String, email: String, password: String, image: UIImage,completion: @escaping (Bool) -> Void) {
        
        imageUploder(image: image) { imageUrl in
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                
                if error != nil {
                    print(error?.localizedDescription as Any)
                    return
                }
                
                guard let uid = result?.user.uid else { return}
                
                let ref = Database.database().reference()
                
                let userRef = ref.child("users").child(uid)
                
                let value = ["username": username, "email": email, "imageUrl": imageUrl]
            
                userRef.updateChildValues(value) { err, ref in
                    
                    if err != nil {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
}
