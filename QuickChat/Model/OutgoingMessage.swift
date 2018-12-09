//
//  OutgoingMessage.swift
//  QuickChat
//
//  Created by iulian david on 12/9/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

//swiftlint:disable force_cast
//swiftlint:disable trailing_whitespace
//swiftlint:disable line_length
class OutgoingMessage {
    let ref = firebase.child(kMESSAGE)
    
    let messageDictionary: NSMutableDictionary
    
    // text
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // location
    convenience init(message: String, latitude: Double, longitude: Double, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        let tempDictionary = NSMutableDictionary(objects: [latitude, longitude], forKeys: [kLATITUDE as NSCopying, kLONGITUDE as NSCopying])
        messageDictionary.addEntries(from: tempDictionary as! [AnyHashable: Any])
    }
    
    // picture
    convenience init(message: String, pictureData: Data, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        let tempDictionary = NSMutableDictionary(objects: [pictureData], forKeys: [kPICTURE as NSCopying])
        messageDictionary.addEntries(from: tempDictionary as! [AnyHashable: Any])
    }
    
    // video
    convenience init(message: String, video: String, thumbnail: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        let tempDictionary = NSMutableDictionary(objects: [video, thumbnail], forKeys: [kVIDEO as NSCopying, kTHUMBNAIL as NSCopying])
        messageDictionary.addEntries(from: tempDictionary as! [AnyHashable: Any])
    }
    
    // audio
    convenience init(message: String, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        let tempDictionary = NSMutableDictionary(objects: [audio], forKeys: [kAUDIO as NSCopying])
        messageDictionary.addEntries(from: tempDictionary as! [AnyHashable: Any])
    }
    
    func sendMessage(chatRoomId: String, item: NSMutableDictionary) {
        let reference = ref.child(chatRoomId).childByAutoId()
        
        item[kMESSAGEID] = reference.key
        
        reference.setValue(item) { (error, _) in
            if error != nil {
                ProgressHUD.showError("Fail to send message: \(error!.localizedDescription)")
            }
        }
        
        //update recent
        //send notification
    }
}
