//
//  AppDelegate.swift
//  Studium
//
//  Created by Vikram Singh on 5/24/20.
//  Copyright © 2020 Vikram Singh. All rights reserved.
//

import UIKit
import ChameleonFramework

//AUTHENTICATION
import RealmSwift
import GoogleSignIn
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var realm: Realm!
    let defaults = UserDefaults.standard
    let app = App(id: Secret.appID)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //print(realm.configuration.fileURL)
//        print("UserDefaults Path: ")
//        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! as String)
        updateTheme(color: K.colorsDict[defaults.string(forKey: "themeColor") ?? "black"] ?? UIColor.black)
        
        if let user = app.currentUser {
            do{
                realm = try Realm(configuration: user.configuration(partitionValue: user.id))
                let assignments = realm.objects(Assignment.self)
                for assignment in assignments{
                    if(assignment.isAutoscheduled && Date() > assignment.endDate){
                        RealmCRUD.deleteAssignment(assignment: assignment)
                    }
                }
            }catch{
                print("Error lol")
            }
            print("User IS signed in.")
        }else {
            defaults.setValue("Guest", forKey: "email")
            print("User is NOT signed in.")
        }
        print("Did finish launching");
        
        //clientID must be specified for Google Authentication
        GIDSignIn.sharedInstance().clientID = Secret.clientID
        GIDSignIn.sharedInstance().serverClientID = Secret.serverClientID
        
        // Initialize Facebook SDK
        FBSDKCoreKit.ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
//        GIDSignIn.sharedInstance().restorePreviousSignIn()
    
        
        
        return true
    }
    
    
    //updates the theme color of the app.
    func updateTheme(color: UIColor){
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        UITabBar.appearance().barTintColor = color // your color
        UITabBarAppearance().backgroundColor = color
    }
    
    func changeTheme(colorKey: String){
//        defaults.setColor(color: color, forKey: "themeColor") // set
        defaults.setValue(colorKey, forKey: "themeColor")
         // get
        updateTheme(color: K.colorsDict[colorKey] ?? UIColor.black)
    }
    
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //this is all google sign in delegate stuff.
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let googleSignIn = GIDSignIn.sharedInstance().handle(url)
        if googleSignIn {
            return true
        }
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return false
    }
    
    
    //this is for ios 8 and older
//    func application(_ application: UIApplication,
//                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//      return GIDSignIn.sharedInstance().handle(url)
//    }
    
    
}
