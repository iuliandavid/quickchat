//
//  IncomingMessage.swift
//  QuickChat
//
//  Created by iulian david on 12/10/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation

//swiftlint:disable trailing_whitespace
public class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView: JSQMessagesCollectionView) {
        self.collectionView = collectionView
    }
    
    func createMessage(dictionary: [String: Any], chatRoomId: String) -> JSQMessage? {
        var message: JSQMessage?
        
        guard let type =  dictionary[kTYPE] as? String else {
            return nil
        }
        
        if type == kTEXT {
            message = createTextMessage(item: dictionary, chatRoomId: chatRoomId)
        }
        
        if type == kLOCATION {
            message = createLocationMessage(item: dictionary, chatRoomId: chatRoomId)
        }
        
        if type == kPICTURE {
            message = createPictureMessage(item: dictionary, chatRoomId: chatRoomId)
        }
        
        if type == kVIDEO {
            //text message
            message = createVideoMessage(item: dictionary, chatRoomId: chatRoomId)
        }
        
        if type == kAUDIO {
            //audio message
        }
        
        return message
    }
    
    func createTextMessage(item: [String: Any], chatRoomId: String) -> JSQMessage {
        guard let name = item[kSENDERNAME] as? String,
            let userId = item[kSENDERID] as? String,
            let dateString = item[kDATE] as? String,
            let date = dateFormatter().date(from: dateString),
            let text = item[kMESSAGE] as? String else {
            fatalError()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
    
    func createPictureMessage(item: [String: Any], chatRoomId: String) -> JSQMessage {
        guard let name = item[kSENDERNAME] as? String,
            let userId = item[kSENDERID] as? String,
            let dateString = item[kDATE] as? String,
            let date = dateFormatter().date(from: dateString),
            let pictText = item[kPICTURE] as? String,
            let picData = Data(base64Encoded: pictText) else {
                fatalError()
        }
        let mediaItem = JSQPhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId)
        mediaItem?.image = UIImage(data: picData)
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createLocationMessage(item: [String: Any], chatRoomId: String) -> JSQMessage {
        guard let name = item[kSENDERNAME] as? String,
            let userId = item[kSENDERID] as? String,
            let dateString = item[kDATE] as? String,
            let date = dateFormatter().date(from: dateString),
            let latitude = item[kLATITUDE] as? Double,
            let longitude = item[kLONGITUDE] as? Double else {
                fatalError()
        }
        let mediaItem = JSQLocationMediaItem(location: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusFromUser(senderId: userId)
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createVideoMessage(item: [String: Any], chatRoomId: String) -> JSQMessage {
        guard let name = item[kSENDERNAME] as? String,
            let userId = item[kSENDERID] as? String,
            let dateString = item[kDATE] as? String,
            let date = dateFormatter().date(from: dateString),
            let videoURLString = item[kVIDEO] as? String,
            let thubnmailURLString = item[kTHUMBNAIL] as? String else {
                fatalError()
        }
        let videoURL = URL(fileURLWithPath: videoURLString)
        let mediaItem = VideoMessage(
            withFileURL: videoURL,
            maskOutgoing: returnOutgoingStatusFromUser(senderId: userId))
        
        BackendlessUtils.downloadVideo(videoUrlString: videoURLString) { (_, filename) in
            guard filename != "" else { return }
            
            let url = URL(fileURLWithPath: fileInDocumentsDirectory(filename: filename))
            
            //download thumbnail
            BackendlessUtils.getAvatarFromURL(url: thubnmailURLString, result: { (thumbnail) in
                mediaItem.status = kSUCCESS
                mediaItem.fileURL = url
                mediaItem.image = thumbnail
                self.collectionView.reloadData()
            })
        }
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func returnOutgoingStatusFromUser(senderId: String) -> Bool {
        
        if let userId = backendless?.userService.currentUser.objectId, userId as String != senderId {
            return true
        } else {
            return false
        }
        
    }
}
