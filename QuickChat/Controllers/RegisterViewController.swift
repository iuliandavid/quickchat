//
//  RegisterViewController.swift
//  QuickChat
//
//  Created by iulian david on 11/25/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit

//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace
class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var newUser: BackendlessUser?
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        newUser = BackendlessUser()
    }
    

    /*
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - IBActions
    @IBAction func registerBtnPressed(_ sender: Any) {
        guard let email = emailTextField.text, email != "",
            let password = passwordTextField.text, password != "",
            let username = usernameTextField.text, username != ""
        else { ProgressHUD.showError("All fields are required!")
            return }
        
        ProgressHUD.show("Registering...", interaction: false)
        register(email: email, username: username, password: password, avatarImage: avatarImage)
    }
    
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
    }
    
    // MARK: - Register backendless user
    private func register(email: String, username: String, password: String, avatarImage: UIImage?) {
        newUser?.email = email as NSString
        newUser?.password = password as NSString
        newUser?.name = username as NSString
        
        if avatarImage == nil {
            newUser?.setProperty("Avatar", object: "")
        } else {
            // upload avatar image
        }
        
        
        
        backendless?.userService.register(newUser, response: { _ in
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.usernameTextField.text = nil
            // dismiss keyboard
            self.view.endEditing(false)
            // login user
            self.loginUser(email: email, password: password)
        }, error: { (fault) in
            if let err = fault {
                ProgressHUD.showError("Error registering user \(err.detail ?? "")")
            }
        })
    }
    
    private func loginUser(email: String, password: String) {
        
        backendless?.userService.login(email, password: password, response: { _ in
            // go to app
            // go to app
            DispatchQueue.main.async { [unowned self] in
                NavigationSingleton.instance.goToApp(viewController: self)
                ProgressHUD.dismiss()
            }
        }, error: { (fault) in
            if let err = fault {
                ProgressHUD.showError("Couldn't login: \(err.detail ?? "")")
            }
        })
    }
}
