//
//  ActivityIndicator.swift
//  ChatApp
//
//  Created by Admin on 24/08/22.
//

import UIKit

fileprivate var aView: UIView?

extension UITableViewController {
    
    func showSpiner() {
        
        //aView = UIView(frame: self.view.bounds)
        aView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 600))
        aView?.backgroundColor = .init(white: 1, alpha: 0.5)
        
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
