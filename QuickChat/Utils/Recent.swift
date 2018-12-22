//
//  Recent.swift
//  QuickChat
//
//  Created by iulian david on 12/4/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Foundation
//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace

func startChat(user1: BackendlessUser, user2: BackendlessUser) -> String {
    let userId1 = user1.objectId as String
    let userId2 = user2.objectId as String
    
    let chatRoomId = userId1.compare(userId2).rawValue < 0
    ? (userId1 + userId2) : (userId2 + userId1)
    
    
    let members = [userId1, userId2]
    
    //create Recents
    createRecent(userId: userId1, chatRoomId: chatRoomId, members: members, withUserUserId: userId2, withUserUsername: user2.name as String, type: kPRIVATE)
    
    createRecent(userId: userId2, chatRoomId: chatRoomId, members: members, withUserUserId: userId1, withUserUsername: user1.name as String, type: kPRIVATE)
    return chatRoomId
}


func createRecent(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {
    firebase
        .child(kRECENT)
        .queryOrdered(byChild: kCHATROOMID)
        .queryEqual(toValue: chatRoomId)
        .observeSingleEvent(of: .value) { snapshot in
            var create = true
            if let recents = (snapshot.value as? NSDictionary)?.allValues as? [NSDictionary] {
                
                for recent in recents where (recent[kUSERID] as? String) == userId {
                    
                    create = false
                    break
                    
                }
            }
            
            
            if create {
                createRecentItem(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserId: withUserUserId, withUserUsername: withUserUsername, type: type)
            }
    }
}

func createRecentItem(userId: String, chatRoomId: String, members: [String], withUserUserId: String, withUserUsername: String, type: String) {
    
    let reference = firebase.child(kRECENT).childByAutoId()
    
    guard let recentID = reference.key else {
        return
    }
    let date = dateFormatter().string(from: Date())
    
    let recent = [kRECENT: recentID, kUSERID: userId,
                  kCHATROOMID: chatRoomId, kMEMBERS: members,
                  kWITHUSERUSERNAME: withUserUsername, kWITHUSERUSERID: withUserUserId,
                  kLASTMESSAGE: "", kCOUNTER: 0, kDATE: date, kTYPE: type ] as [String: Any]
    
    reference.setValue(recent) { (error, _) in
        if error != nil {
            ProgressHUD.showError("Couldn't create recent: \(error!.localizedDescription)")
        }
    }
}

func restartRecentChat(recent: [String: Any]) {
    if let type = recent[kTYPE] as? String, type == kPRIVATE {
        guard let members = recent[kMEMBERS] as? [String],
            let chatRoomId = recent[kCHATROOMID] as? String,
            let withUserUserId = backendless?.userService.currentUser.objectId as String?,
            let withUserUsername = backendless?.userService.currentUser.name as String? else {
                return
        }
        for userId in recent[kMEMBERS] as? [String] ?? [] where userId != withUserUserId as String {
            createRecent(userId: userId, chatRoomId: chatRoomId, members: members, withUserUserId: withUserUserId as String, withUserUsername: withUserUsername as String, type: kPRIVATE)
        }
    }
    
    if let type = recent[kTYPE] as? String, type == kGROUP {
        // TODO
    }
}

func updateRecents(chatRoomId: String, lastMessage: String) {
    firebase
        .child(kRECENT)
        .queryOrdered(byChild: kCHATROOMID)
        .queryEqual(toValue: chatRoomId)
        .observeSingleEvent(of: .value) { snapshot in
            if let snapshotValue = snapshot.value as? [String: Any] {
               //update recent item
                updateRecentItem(recent: snapshotValue, lastMessage: lastMessage)
            }
            
    }
}

func updateRecentItem(recent: [String: Any], lastMessage: String) {
    guard let recentId = recent[kRECENTID] as? String,
        let userId = recent[kUSERID] as? String,
        let currentUserId = backendless?.userService.currentUser.objectId else {
        return
    }
    let date = dateFormatter().string(from: Date())
    
    var counter = recent[kCOUNTER] as? Int ?? 0
    
    if userId != currentUserId as String {
        counter += 1
    }
    
    let values = [kLASTMESSAGE: lastMessage, kCOUNTER: counter, kDATE: date] as [String: Any]
    
    firebase
        .child(kRECENT)
        .child(recentId)
        .updateChildValues(values) { (error, _) in
            if error != nil {
                ProgressHUD.showError("Couldn't update recent: \(error!.localizedDescription)")
            }
    }
}

func updateChatStatus(chat: [String: Any], chatRoomId: String) {
    let value = [kSTATUS: kREAD]
    guard let messageid = chat[kMESSAGEID] as? String else {
        return
    }
    firebase
        .child(kMESSAGE)
        .child(chatRoomId)
        .child(messageid)
        .updateChildValues(value)
}

class RecentBuilder {
    private var recent = Recent()
    
    func setUserId(_ userId: String) -> RecentBuilder {
        recent.userId = userId
        return self
    }
    
    
    func setChatRoomId(_ chatRoomId: String) -> RecentBuilder {
        recent.chatRoomId = chatRoomId
        return self
    }
    func withMembers(_ members: [String]) -> RecentBuilder {
        recent.members = members
        return self
    }
    func withUserId(_ withUserUserId: String) -> RecentBuilder {
        recent.withUserUserId = withUserUserId
        return self
    }
    func withUserName(_ withUserUsername: String) -> RecentBuilder {
        recent.withUserUsername = withUserUsername
        return self
    }
    func withType(_ type: String) -> RecentBuilder {
        recent.type = type
        return self
    }
    func build() -> Recent {
        return recent
    }
    
    class Recent {
        fileprivate var userId: String = ""
        fileprivate var chatRoomId: String = ""
        fileprivate var members: [String] = []
        fileprivate var withUserUserId: String = ""
        fileprivate var withUserUsername: String = ""
        fileprivate var type: String = ""
    }
}
