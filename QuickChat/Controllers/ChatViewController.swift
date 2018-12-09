//
//  ChatViewController.swift
//  QuickChat
//
//  Created by iulian david on 12/9/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
import AVKit

//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace
class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //swiftlint:disable force_cast
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let ref = firebase.child(kMESSAGE)
    
    
    var loadCount = 0
    var max = 0
    var min = 0
    
    var messages: [JSQMessage] = []
    var objects: [NSDictionary] = []
    var loaded: [NSDictionary] = []
    
    var avatarImagesDictionary: NSMutableDictionary?
    var avatarDictionary: NSMutableDictionary?
    
    var members: [String] = []
    var withUsers: [BackendlessUser] = []
    var titleName: String?
    
    var chatRoomId: String!
    var isGroup: Bool?
    
    var initialLoadComplete: Bool = false
    var showAvatars = true
    var firstLoad: Bool?
    
    let outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    let incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userId = backendless?.userService.currentUser.objectId as String?, userId != "",
            let userName = backendless?.userService.currentUser.name as String? else {
                fatalError("User has logged out")
        }
        self.senderId = userId
        self.senderDisplayName = userName
        self.title = titleName
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    // MARK: JSQMeesages Data Source
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as? JSQMessagesCollectionViewCell else {
            fatalError("invalid settings")
        }
        
        let data = messages[indexPath.row]
        
        if data.senderId == senderId {
            cell.textView.textColor = .white
        } else {
            cell.textView.textColor = .black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        let data = messages[indexPath.row]
        
        return data
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        if data.senderId == senderId {
           return outgoingBubble
        } else {
            return incomingBubble
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
    
        return nil
    }
    //swiftlint:disable line_length
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 50
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    //swiftlint:disable line_length
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 50
    }
    
    // MARK: JSQMessages Delegate Function
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != ""{
            sendMessage(text: text, date: date)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
    }
    
    // MARK: Send Message
    func sendMessage(text: String? = nil, date: Date, picture: UIImage? = nil, location: String? = nil, video: URL? = nil, audio: String? = nil) {
        
        var outgoingMessage: OutgoingMessage?
        //text message
        if let text = text {
            //send text message
            outgoingMessage = OutgoingMessage(message: text, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kTEXT)
        }
        
        //image message
        if let picture = picture, let data = picture.jpegData(compressionQuality: 1.0) {
            //send image message
            outgoingMessage = OutgoingMessage(message: "", pictureData: data, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kPICTURE)
        }
        
        
        //video message
        if let video = video {
            //send video message
            outgoingMessage = OutgoingMessage(message: "", senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kVIDEO)
        }
        
        //audio message
        if let audioPath = audio {
            //send audio message
            outgoingMessage = OutgoingMessage(message: "", senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kAUDIO)
        }
        
        //location message
        if let location = location {
            //send location message
            outgoingMessage = OutgoingMessage(message: "", senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kLOCATION)
        }
        
        guard let createdOutgoingMessage = outgoingMessage else {
            fatalError("No message")
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        createdOutgoingMessage.sendMessage(chatRoomId: chatRoomId, item: createdOutgoingMessage.messageDictionary)
    }
}
