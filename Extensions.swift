//
//  Extensions.swift
//  onTheMap
//
//  Created by Mohammed Jarad on 20/05/2019.
//  Copyright © 2019 Jarad. All rights reserved.
//

import UIKit


extension UIViewController {
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUIUpdatesOnMain {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
    func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        }
    }
    
    func handleLogOut(response: Session? , error: Error?){
        guard response != nil else {
            showInfo(withMessage: "Unable To Log Out")
            return
        }
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "logOutAccapted", sender: nil)
        }
    }
}

