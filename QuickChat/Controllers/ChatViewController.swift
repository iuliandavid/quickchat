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
    var objects: [[String: Any]] = []
    var loaded: [[String: Any]] = []
    
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
        loadMessages()
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
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        return nil
    }
    //swiftlint:disable line_length
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        return 0.0
    }
    
    // MARK: JSQMessages Delegate Function
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != ""{
            sendMessage(text: text, date: date)
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let camera = Camera(delegate: self)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { _ in
                camera.presentMultiCamera(target: self, canEdit: true)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { _ in
            camera.presentVideoLibray(target: self, canEdit: true)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { _ in
            camera.presentPhotoLibray(target: self, canEdit: true)
        }
        
        let audioMessage = UIAlertAction(title: "Audio Message", style: .default) { _ in
            
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { _ in
            
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(audioMessage)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Load more messages action
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        loadMoreMessages(maxNumber: max, minNumber: min)
        self.collectionView.reloadData()
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
            outgoingMessage = OutgoingMessage(message: kPICTURE, pictureData: data, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kPICTURE)
        }
        
        
        //video message
        if let video = video {
            //send video message
            outgoingMessage = OutgoingMessage(message: kVIDEO, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kVIDEO)
        }
        
        //audio message
        if let audioPath = audio {
            //send audio message
            outgoingMessage = OutgoingMessage(message: kAUDIO, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kAUDIO)
        }
        
        //location message
        if let location = location {
            //send location message
            outgoingMessage = OutgoingMessage(message: kLOCATION, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kLOCATION)
        }
        
        guard let createdOutgoingMessage = outgoingMessage else {
            fatalError("No message")
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        createdOutgoingMessage.sendMessage(chatRoomId: chatRoomId, item: createdOutgoingMessage.messageDictionary)
    }
    
    
    // MARK: Load Messages
    func loadMessages() {
        let acceptedMessageTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
        
        ref
            .child(chatRoomId)
            .observe(.childAdded) { (snapshot) in
                // update UI
                
                if let item = snapshot.value as? [String: Any],
                    let type = item[kTYPE] as? String,
                    acceptedMessageTypes.contains(type) {
                    if self.initialLoadComplete {
                        let isIncoming = self.insertMessage(item: item)
                        if isIncoming {
                            JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                        }
                        self.finishSendingMessage(animated: true)
                    } else {
                        self.loaded.append(item)
                    }
                }
        }
        ref
            .child(chatRoomId)
            .observe(.childChanged) { _ in
                // update message
        }
        
        
        ref
            .child(chatRoomId)
            .observeSingleEvent(of: .value) { _ in
                self.insertMessages()
                self.finishSendingMessage(animated: false)
                self.initialLoadComplete = true
        }
        self.collectionView.reloadData()
    }
    
   
    
    private func insertMessages() {
        max = loaded.count - loadCount
        min = max - kNUMBEROFMESSAGES
        
        if min < 0 {
            min = 0
        }
        
        for iter in min..<max {
            let item = loaded[iter]
            _ = insertMessage(item: item)
            loadCount += 1
        }
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        max = minNumber - 1
        min = max - kNUMBEROFMESSAGES
        if min < 0 {
            min = 0
        }
        
        for iter in (min...max).reversed() {
            let item = loaded[iter]
            _ = insertNewMessage(item: item)
            loadCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadCount != loaded.count)
    }
    
    
    func insertNewMessage(item: [String: Any]) -> Bool {
        if let message = IncomingMessage.createMessage(dictionary: item, chatRoomId: chatRoomId) {
            objects.insert(item, at: 0)
            messages.insert(message, at: 0)
        }
        return isIncoming(item: item)
    }
    
    private func insertMessage(item: [String: Any]) -> Bool {
        
        if let senderId = item[kSENDERID] as? String, senderId != self.senderId {
            //update status
        }
        
        if let message = IncomingMessage.createMessage(dictionary: item, chatRoomId: chatRoomId) {
            objects.append(item)
            messages.append(message)
        }
        return isIncoming(item: item)
    }
    
    func isIncoming(item: [String: Any]) -> Bool {
        if let senderId = item[kSENDERID] as? String, senderId != self.senderId {
            return true
        } else {
            return false
        }
    }
}


// MARK: UIImagePickerControllerDelegate function
extension ChatViewController {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let picture = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        sendMessage(text: nil, date: Date(), picture: picture, video: video)
        picker.dismiss(animated: true, completion: nil)
    }
}
