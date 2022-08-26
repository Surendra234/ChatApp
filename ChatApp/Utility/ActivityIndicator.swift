//
//  ActivityIndicator.swift
//  ChatApp
//
//  Created by Admin on 24/08/22.
//

import UIKit

fileprivate var aView: UIView?

extension UIViewController {
    
    func showSpiner() {
        
        aView = UIView(frame: self.view.bounds)
        aView?.backgroundColor = .red
        
        let ai = UIActivityIndicatorView(style: .large)
        ai.center = aView!.center
        ai.startAnimating()
        
        aView?.addSubview(ai)
        self.view.addSubview(aView!)
    }
    
    func removeSpiner() {
        
        aView?.removeFromSuperview()
        aView = nil
    }
}
