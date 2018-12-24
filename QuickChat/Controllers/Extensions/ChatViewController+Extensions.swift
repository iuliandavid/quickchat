//
//  ChatViewController+Extensions.swift
//  QuickChat
//
//  Created by iulian david on 12/23/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace
// MARK: UIImagePickerControllerDelegate function
extension ChatViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let picture = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, video: video)
        picker.dismiss(animated: true, completion: nil)
    }
}
