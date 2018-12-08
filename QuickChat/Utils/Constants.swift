//
//  Constants.swift
//  QuickChat
//
//  Created by iulian david on 11/25/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import Firebase

//Backendless
struct BackendlessConstants {
    static let ApplicationID = "BF093F65-207E-2EB6-FF0D-BBE8869BD000"
    static let ApiKey = "CC38BFB5-6F4D-26E1-FF2D-6218C5B74800"
    static let ServerUrl = "https://api.backendless.com"
}

var backendless = Backendless.sharedInstance()

public let kMAXDURATION = 5.0

//firebase
var firebase = Database.database().reference()
//recent
public let kRECENT = "Recent"
public let kUSERID = "userId"
public let kDATE = "date"
public let kCHATROOMID = "chatRoomID"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kDESCRIPTION = "description"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGE = "Message"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"
