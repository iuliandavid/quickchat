//
//  NavigationSingleton.swift
//  QuickChat
//
//  Created by iulian david on 11/25/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit

class NavigationSingleton {
   static let instance = NavigationSingleton()
    
    func goToApp(viewController: UIViewController) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RecentsVC") as? UITabBarController else {
            return
        }
        
        vc.selectedIndex = 0
        viewController.present(vc, animated: true, completion: nil)
    }
}
