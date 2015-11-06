//
//  AppDelegate.swift
//  Impressive
//
//  Created by Andrew Schmidt on 2/17/15.
//  Copyright (c) 2015 Andrew Schmidt. All rights reserved.
//

import UIKit
import ImpData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var backgroundTask: UIBackgroundTaskIdentifier!


//    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
//        // Handle notifications.
//
//        println("APPDELEGATE: Received notification!")
//    }
    
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]?) -> Void)) {
        // Handle requests from the watch.
        
        print("APPDELEGATE: Awoken by Watch!")

        for (key, value) in userInfo! {
            switch key {
                case "loadDaily":
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        
                        let taskID = self.beginBackgroundUpdateTask()
                        
                        LoadSave.sharedInstance.loadDaily() {
                            dailyRecipe in
                            
                            reply(["success": "PARENTAPP: Found a daily recipe and saved it to the shared app group."])
                            self.endBackgroundUpdateTask(taskID)
                        }
                        
                    })
                    
                default:
                    print("APPDELEGATE: Something broke.")
                }
        }
    }
    
        func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
            return UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({})
        }
        
        func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
            UIApplication.sharedApplication().endBackgroundTask(taskID)
        }
    
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        application.statusBarHidden = true
        
        self.window?.tintColor = UIColor.coffeeColor()
        
        // Below is from http://stackoverflow.com/questions/18969248/how-to-draw-a-transparent-uitoolbar-or-uinavigationbar-in-ios7
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.backgroundColor = .clearColor()
        navigationBarAppearance.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBarAppearance.shadowImage = UIImage()
        
        return true
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

