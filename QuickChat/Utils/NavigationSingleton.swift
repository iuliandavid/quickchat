//
//  NavigationSingleton.swift
//  QuickChat
//
//  Created by iulian david on 11/25/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit

//swiftlint:disable trailing_whitespace
class NavigationSingleton {
   static let instance = NavigationSingleton()
    
    func goToApp(viewController: UIViewController) {
        guard let tabVc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "RecentsVC") as? UITabBarController else {
            return
        }
        
        tabVc.selectedIndex = 0
        viewController.present(tabVc, animated: true, completion: nil)
    }
}
