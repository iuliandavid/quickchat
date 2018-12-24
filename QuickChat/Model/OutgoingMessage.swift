//
//  OutgoingMessage.swift
//  QuickChat
//
//  Created by iulian david on 12/9/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

//swiftlint:disable trailing_whitespace
//swiftlint:disable line_length
class OutgoingMessage {
    let ref = firebase.child(kMESSAGE)
    
    var messageDictionary: [String: Any]
    
    // text
    init(message: String? = nil, senderId: String, senderName: String, date: Date, status: String, type: String) {
        messageDictionary = [kSENDERID: senderId,
                             kSENDERNAME: senderName,
                             kDATE: dateFormatter().string(from: date),
                             kSTATUS: status,
                             kTYPE: type
        ]
        
        if let text = message {
            messageDictionary[kMESSAGE] = text
        }
    }
    
    // location
    convenience init(message: String? = nil, latitude: Double, longitude: Double, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        messageDictionary[kLATITUDE] = latitude
        messageDictionary[kLONGITUDE] = longitude
    }
    
    // picture
    convenience init(message: String? = nil, pictureData: Data, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        messageDictionary[kPICTURE] =  pictureData.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }
    
    // video
    convenience init(message: String? = nil, video: String, thumbnail: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        messageDictionary[kVIDEO] = video
        messageDictionary[kTHUMBNAIL] = thumbnail
    }
    
    // audio
    convenience init(message: String? = nil, audio: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        self.init(message: message, senderId: senderId, senderName: senderName, date: date, status: status, type: type)
        messageDictionary[kAUDIO] = audio
    }
    
    func sendMessage(chatRoomId: String) {
        guard let item = self.messageDictionary as? [String: Any] else { return  }
        let reference = ref.child(chatRoomId).childByAutoId()
        var values: [String: Any] = [:]
        item.forEach {values[$0] = $1}
        values[kMESSAGEID] = reference.key
        
        reference.setValue(values) { (error, _) in
            if error != nil {
                ProgressHUD.showError("Fail to send message: \(error!.localizedDescription)")
            }
        }
        
        //update recent
        //send notification
    }
    
    func sendMessage(chatRoomId: String, item: [String: Any]) {
        let reference = ref.child(chatRoomId).childByAutoId()
        var values: [String: Any] = [:]
        item.forEach {values[$0] = $1}
        values[kMESSAGEID] = reference.key
        
        reference.setValue(values) { (error, _) in
            if error != nil {
                ProgressHUD.showError("Fail to send message: \(error!.localizedDescription)")
            }
        }
        
        //update recent
        //send notification
    }
}
