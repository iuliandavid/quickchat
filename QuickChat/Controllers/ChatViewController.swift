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
//swiftlint:disable line_length
class ChatViewController: JSQMessagesViewController,
    UINavigationControllerDelegate {
    
    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
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
        
        // Just a hack to be sure the location gets renderd
        if cell.textView != nil {
            if data.senderId == senderId {
                cell.textView.textColor = .white
            } else {
                cell.textView.textColor = .black
            }
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
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        let message = objects[indexPath.row]
        
        if let status = message[kSTATUS] as? String, indexPath.row == (messages.count - 1) {
            return NSAttributedString(string: status)
        } else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if !isIncoming(item: objects[indexPath.row]) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
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
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
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
    func sendMessage(text: String? = nil, date: Date = Date(), picture: UIImage? = nil, location: String? = nil, video: URL? = nil, audio: String? = nil) {
        
        var outgoingMessage: OutgoingMessage?
        //text message
        if let text = text {
            //send text message
            outgoingMessage = OutgoingMessage(message: text, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kTEXT)
            finishOutgoingMessage(outgoingMessage: outgoingMessage)
        }
        
        //image message
        if let picture = picture, let data = picture.jpegData(compressionQuality: 1.0) {
            //send image message
            outgoingMessage = OutgoingMessage(message: kPICTURE, pictureData: data, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kPICTURE)
            finishOutgoingMessage(outgoingMessage: outgoingMessage)
        }
        
        
        //video message
        if let video = video,
            let videoData = try? Data(contentsOf: video),
            let picture = getThumbnailImage(for: video) {
            let squared = picture.squareImage(side: 320)
            if let dataThumbnail = squared.jpegData(compressionQuality: 0.3) {
                BackendlessUtils.uploadVideo(video: videoData, thumbnail: dataThumbnail) { (videoLink, thumbnailLink) in
                    if let videoLink = videoLink,
                        let thumbnailLink = thumbnailLink {
                        //send video message
                        outgoingMessage = OutgoingMessage(message: kVIDEO, video: videoLink, thumbnail: thumbnailLink, senderId: self.senderId, senderName: self.senderDisplayName, date: Date(), status: kDELIVERED, type: kVIDEO)
                        
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage()
                        
                        outgoingMessage?.sendMessage(chatRoomId: self.chatRoomId)
                        return
                    }
                }
            }
           
        }
        
        //audio message
        if audio != nil {
            //send audio message
            outgoingMessage = OutgoingMessage(message: kAUDIO, senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kAUDIO)
            finishOutgoingMessage(outgoingMessage: outgoingMessage)
        }
        
        //location message
        if location != nil {
            //send location message
            if let latitude = appDelegate?.coordinates?.latitude, let longitude = appDelegate?.coordinates?.longitude {
                let text = kLOCATION
                outgoingMessage = OutgoingMessage(message: text, latitude: Double(latitude), longitude: Double(longitude), senderId: senderId, senderName: senderDisplayName, date: Date(), status: kDELIVERED, type: kLOCATION)
                finishOutgoingMessage(outgoingMessage: outgoingMessage)
            }
            
        }
        
        
    }
    
    private func finishOutgoingMessage(outgoingMessage: OutgoingMessage?) {
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
            .observe(.childChanged) { [weak self] snapshot in
                // update message
                guard let item = snapshot.value as? [String: Any] else {
                    return
                }
                self?.updateMessage(item: item)
        }
        
        
        ref
            .child(chatRoomId)
            .observeSingleEvent(of: .value) { [weak self] _ in
                self?.insertMessages()
                self?.finishSendingMessage(animated: false)
                self?.initialLoadComplete = true
        }
        self.collectionView.reloadData()
    }
    
    func updateMessage(item: [String: Any]) {
        if let index = objects.firstIndex(where: { temp in
            return item[kMESSAGEID] as? String == temp[kMESSAGEID] as? String
        }) {
            objects[index] = item
            self.collectionView.reloadData()
        }
        
//        alternative
//        for index in 0 ..< objects.count {
//            let temp = objects[index]
//            if item[kMESSAGEID] as? String == temp[kMESSAGEID] as? String {
//                objects[index] = item
//                self.collectionView.reloadData()
//            }
//        }
        
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
        
        let incomingMessage = IncomingMessage(collectionView: self.collectionView)
        if let message = incomingMessage.createMessage(dictionary: item, chatRoomId: chatRoomId) {
            objects.insert(item, at: 0)
            messages.insert(message, at: 0)
        }
        return isIncoming(item: item)
    }
    
    private func insertMessage(item: [String: Any]) -> Bool {
        let incomingMessage = IncomingMessage(collectionView: self.collectionView)
        if let senderId = item[kSENDERID] as? String, senderId != self.senderId {
            updateChatStatus(chat: item, chatRoomId: chatRoomId)
        }
        
        if let message = incomingMessage.createMessage(dictionary: item, chatRoomId: chatRoomId) {
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
    
    func haveAccessToUserLocation() -> Bool {
        
        //it's faster like this than appDelegate?.locationManager != nil
        // see https://stackoverflow.com/questions/45441878/in-swift-why-is-let-this-faster-then-this-nil#
        //swiftlint:disable unused_optional_binding
        if let _ = appDelegate?.locationManager {
            return true
        } else {
            ProgressHUD.showError("Please give access to location in Setting")
            return false
        }
    }
}
