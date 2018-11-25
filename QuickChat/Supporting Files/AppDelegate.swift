//
//  AppDelegate.swift
//  QuickChat
//
//  Created by iulian david on 11/23/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import NotificationCenter

// swiftlint:disable line_length
// swiftlint:disable trailing_whitespace
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        backendless?.hostURL = BackendlessConstants.ServerUrl
        backendless?.initApp(BackendlessConstants.ApplicationID, apiKey: BackendlessConstants.ApiKey)
        
        FirebaseApp.configure()
        //make the database to be used offline
        Database.database().isPersistenceEnabled = true
        
        return true
    }

}
