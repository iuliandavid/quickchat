//
//  WelcomeViewController.swift
//  QuickChat
//
//  Created by iulian david on 11/25/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
import Firebase

//swiftlint:disable trailing_whitespace
class WelcomeViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        backendless?.userService.setStayLoggedIn(true)
        
        if backendless?.userService.currentUser != nil {
            // go to app
            DispatchQueue.main.async {
            NavigationSingleton.instance.goToApp(viewController: self)
            }
        }
    }
    
    
    @IBAction func loginBtnPressed(_ sender: Any) {
        //Test empty fields
        guard let email = emailTextField.text, email != "", let password = passwordTextField.text, password != "" else {
            ProgressHUD.showError("Empty Email or Password")
            return
        }
        
        ProgressHUD.show("Logging in...", interaction: false)
        loginUser(email: email, password: password)
    }
    
    @IBAction func registerBtnPressed(_ sender: Any) {
        
    }
   
    private func loginUser(email: String, password: String) {
        ProgressHUD.dismiss()
        
        backendless?.userService.login(email, password: password, response: { (user) in
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            // dismiss keyboard
            self.view.endEditing(false)
            
            // go to app
            NavigationSingleton.instance.goToApp(viewController: self)
        }, error: { (fault) in
            if let err = fault {
                ProgressHUD.showError("Couldn't login: \(err.detail ?? "")")
            }
        })
    }
}
