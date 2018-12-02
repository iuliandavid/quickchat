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
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // Create a new image picker
        let camera = Camera(delegate: self)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .default) { _ in
            camera.presentPhotoCamera(target: self, canEdit: true)
        }
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { _ in
            camera.presentPhotoLibray(target: self, canEdit: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - Register backendless user
    private func register(email: String, username: String, password: String, avatarImage: UIImage?) {
        newUser?.email = email as NSString
        newUser?.password = password as NSString
        newUser?.name = username as NSString
        
        let uploadableAvatarImage: UIImage
        if let avatarImage = avatarImage {
            uploadableAvatarImage = avatarImage
        } else {
            uploadableAvatarImage = UIImage.createImage(text: username)
        }
        
        backendless?.userService.register(self.newUser, response: { [unowned self] _ in
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
            self.usernameTextField.text = nil
            // dismiss keyboard
            self.view.endEditing(false)
            // login user
            self.loginUser(email: email, password: password)
            self.uploadAvatar(image: uploadableAvatarImage)
        }, error: { (fault) in
            if let err = fault {
                ProgressHUD.showError("Error registering user \(err.detail ?? "")")
            }
        })
        
    }
    
    private func uploadAvatar(image: UIImage) {
        BackendlessUtils.uploadAvatar(
            uploadDirectory: "/avatars/",
            image: image) { (urlFile, fault) in
                if let err = fault {
                    ProgressHUD.showError("Couldn't upload avatar: \(err.detail ?? "")")
                } else {
                    guard let urlFile = urlFile, let user = backendless?.userService.currentUser else {
                        return
                    }
                    let properties = ["Avatar": urlFile]
                    user.updateProperties(properties)
                    backendless?.userService
                        .update(
                            user,
                            response: { _ in },
                            error: { fault in
                                if let err = fault {
                                    ProgressHUD.showError("Error updating user avatar \(err.detail ?? "")")
                                }
                        })
                }
        }
    }
    
    private func loginUser(email: String, password: String) {
        
        backendless?.userService.login(email, password: password, response: { _ in
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


// MARK: - Extensions
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // called when the user cancels selecting an image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // called when the user has finished selecting an image
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage
            ?? info[.originalImage] as? UIImage else {
            ProgressHUD.showError("Couldn't get a picture from the image picker!")
            return
        }
        
        self.avatarImage = image
        
        // Get rid of the view controller
        picker.dismiss(animated: true, completion: nil)
    }
}
