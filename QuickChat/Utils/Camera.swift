//
//  Camera.swift
//  QuickChat
//
//  Created by iulian david on 11/30/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
import MobileCoreServices

//swiftlint:disable trailing_whitespace
class Camera {
    weak var delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    
    init(delegate: UIImagePickerControllerDelegate & UINavigationControllerDelegate) {
        self.delegate = delegate
    }
    
    func presentPhotoLibray(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
            && !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if availableTypes.contains(type) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        //present the imagepicker
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentMultiCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let type1 = kUTTypeImage as String
        let type2 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if availableTypes.contains(type1) {
                imagePicker.mediaTypes = [type1, type2]
                imagePicker.sourceType = .camera
            }
        }
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePicker.cameraDevice = .rear
        } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
            imagePicker.cameraDevice = .front
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        
        //present the imagepicker to user
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentPhotoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let type1 = kUTTypeImage as String
        
        let imagePicker = UIImagePickerController()
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if availableTypes.contains(type1) {
                imagePicker.mediaTypes = [type1]
                imagePicker.sourceType = .camera
            }
        }
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePicker.cameraDevice = .rear
        } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
            imagePicker.cameraDevice = .front
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        
        //present the imagepicker to user
        target.present(imagePicker, animated: true, completion: nil)
    }
    
    func presentVideoCamera(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let type1 = kUTTypeMovie as String
        
        let imagePicker = UIImagePickerController()
        
        if let availableTypes = UIImagePickerController.availableMediaTypes(for: .camera) {
            if availableTypes.contains(type1) {
                imagePicker.mediaTypes = [type1]
                imagePicker.sourceType = .camera
                imagePicker.videoMaximumDuration = kMAXDURATION
            }
        }
        
        if UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePicker.cameraDevice = .rear
        } else if UIImagePickerController.isCameraDeviceAvailable(.front) {
            imagePicker.cameraDevice = .front
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = delegate
        
        //present the imagepicker to user
        target.present(imagePicker, animated: true, completion: nil)
    }
    func presentVideoLibray(target: UIViewController, canEdit: Bool) {
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
            && !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
//        imagePicker.videoMaximumDuration = kMAXDURATION
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imagePicker.sourceType = .photoLibrary
            
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
                if availableTypes.contains(type) {
                    // Set up defaults
                    imagePicker.mediaTypes = [type]
                    imagePicker.allowsEditing = canEdit
                }
            }
        } else if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            imagePicker.sourceType = .savedPhotosAlbum
            if let availableTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) {
                if availableTypes.contains(type) {
                    imagePicker.mediaTypes = [type]
                }
            }
        } else {
            return
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = delegate
        //present the imagepicker
        target.present(imagePicker, animated: true, completion: nil)
    }
}
