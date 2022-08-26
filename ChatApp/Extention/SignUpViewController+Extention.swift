//
//  SignUpVC+UI.swift
//  ChatApp
//
//  Created by Admin on 20/08/22.
//

import UIKit

extension SignUpViewController {
    
    // setup profile image
    func setupAvtar() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker(tapGestureRecognizer:)))
        profileImageTap.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(tapGestureRecognizer: UITapGestureRecognizer) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        }
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageSelected = info[.editedImage] as? UIImage {
            profileImageTap.image = imageSelected
        }
        
        if let imageOrignal = info[.originalImage] as? UIImage {
            profileImageTap.image = imageOrignal
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SignUpViewController {
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
