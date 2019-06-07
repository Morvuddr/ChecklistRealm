//
//  AppDelegate.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 03/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import UserNotifications
import CloudKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var presenter: PasscodeLockPresenter?
    var syncEngine: SyncEngine?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window?.backgroundColor = UIColor.white
        ChecklistFunctions.shared.configureMigration()
        setupNSUbiquitousKeyValueStoreObserver()
        setupRealmDBObserver()
        
        application.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let configuration = PasscodeLockConfiguration()
        presenter = PasscodeLockPresenter(mainWindow: self.window,
                                          configuration: configuration,
                                          state: PasscodeLockViewController.LockState.enterPasscode.getState())
        presenter?.presentPasscodeLock()
        
        return true
    }
    
    func setupNSUbiquitousKeyValueStoreObserver(){
         NotificationCenter.default.addObserver(self, selector: #selector(onUbiquitousKeyValueStoreDidChangeExternally(notification:)), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
    }
    
    func setupRealmDBObserver(){
        syncEngine = SyncEngine(objects: [SyncObject<ChecklistItem>()], databaseScope: .private, container: CKContainer.init(identifier: "iCloud.testtasks"))
    }
    
    @objc func onUbiquitousKeyValueStoreDidChangeExternally(notification:Notification)
    {
        NSUbiquitousKeyValueStore.default.synchronize()
        if let changedKeys = notification.userInfo!["NSUbiquitousKeyValueStoreChangedKeysKey"] as? [String] {
            if changedKeys.contains("shouldRemind") || changedKeys.contains("remindHours") || changedKeys.contains("remindMinutes"){
                let realm = ChecklistFunctions.shared.realm
                let data = realm.objects(ChecklistData.self).first!
                ChecklistFunctions.shared.updateNotifications(in: data)
            }
        }
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
       
        let configuration = PasscodeLockConfiguration()
        presenter = PasscodeLockPresenter(mainWindow: self.window,
                                          configuration: configuration,
                                          state: PasscodeLockViewController.LockState.enterPasscode.getState())
        presenter?.presentPasscodeLock()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let dict = userInfo as! [String: NSObject]
        let notification = CKNotification(fromRemoteNotificationDictionary: dict)
        
        if let subscriptionID = notification?.subscriptionID, IceCreamSubscription.allIDs.contains(subscriptionID) {
            NotificationCenter.default.post(name: Notifications.cloudKitDataDidChangeRemotely.name, object: nil, userInfo: userInfo)
        }
        completionHandler(.newData)
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

}
