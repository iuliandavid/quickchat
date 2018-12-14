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
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        locationManagerStart()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        locationManagerStop()
    }
    
    // MARK: Location Manager
    func locationManagerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestWhenInUseAuthorization()
        }
        locationManager?.startUpdatingLocation()
    }

    func locationManagerStop() {
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: Location ManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            //restricted by e.g. parental controls. User can't Location Services
            break
        case .denied:
            locationManager = nil
            print("denied location")
            //user denied your app access to Location Services, but can grant access from Settings.app
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            coordinates = location.coordinate
        }
    }
}
