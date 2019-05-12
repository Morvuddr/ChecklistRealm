//
//  ChecklistFunctions.swift
//  Checklist
//
//  Created by Игорь Бопп on 26/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import UserNotifications

class ChecklistFunctions {
    
    private init(){}
    static let shared = ChecklistFunctions()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var currentSchemaVersion: UInt64 = 2
    
    
    func createData(){
        
        let data = Data()
        
        do {
            
            try realm.write{
                realm.add(data)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func createChecklistItem(_ data: Data,_ checklistItem: ChecklistItem){
        
        do {
            
            try realm.write{
                data.checklistItems.insert(checklistItem, at: 0)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func updateChecklistItem(at index: Int, title: String, additionalInfo: String, dueDate: Date?, shouldRemind: Bool, in data: Data){
        
        do {
            try realm.write{
                
                data.checklistItems[index].title = title
                data.checklistItems[index].additionalInfo = additionalInfo
                data.checklistItems[index].dueDate = dueDate
                data.checklistItems[index].shouldRemind = shouldRemind
                
            }
        } catch {
            print(error)
        }
        
    }
    
    func deleteChecklistItem(at index: Int, in data: Data){
        
        do {
            try realm.write{
                
                data.checklistItems.remove(at: index)
                
            }
        } catch {
            print(error)
        }
        
    }
    
    func sortChecklistItems(in data: Data){
        
        do {
            try realm.write{
                
                data.checklistItems.sort(){
                    $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
                }
                
                data.checklistItems.sort() {
                    !$0.checked && $1.checked
                }
                
            }
        } catch {
            print(error)
        }
        
        
        
    }
    
    func toggleChecked(at index: Int, in data: Data){
        
        do {
            try realm.write{
                
                data.checklistItems[index].checked = !data.checklistItems[index].checked
                
            }
        } catch {
            print(error)
        }
        
    }
    
    // MARK: - Migrations
    
    func configureMigration() {
  
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if oldSchemaVersion < 1 {
                                                self.migrateFrom0To1(with: migration)
                                            }
                                            
                                            if oldSchemaVersion < 2{
                                                self.migrateFrom1To2(with: migration)
                                            }
                                            
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    func migrateFrom0To1(with migration: Migration){
        migration.enumerateObjects(ofType: ChecklistItem.className()) { (_, newChecklistItem) in
            newChecklistItem?["latitude"] = Double(0)
            newChecklistItem?["longitude"] = Double(0)
        }
    }
    
    func migrateFrom1To2(with migration: Migration){
        migration.enumerateObjects(ofType: ChecklistItem.className()) { (oldChecklistItem, newChecklistItem) in
            let date: Date? = nil
            newChecklistItem?["itemID"] = UUID().uuidString
            newChecklistItem?["dueDate"] = date
            newChecklistItem?["shouldRemind"] = false
        }
    }
    
    // MARK: - Notifications
    
    func scheduleNotification(forItemAt index: Int, in data: Data) {
        removeNotification(forItemAt: index, in: data)
        if let dueDate = data.checklistItems[index].dueDate{
            if dueDate.timeIntervalSinceNow > 0 {
                
                let calendar = Calendar(identifier: .gregorian)
                let diff = calendar.dateComponents([.hour, .minute], from: Date(), to: dueDate)
                
                if (diff.hour! > 1) || (diff.hour! == 1 && diff.minute! > 0)  {
                    
                    let earlyDate = Calendar.current.date(byAdding: .hour, value: -1, to: dueDate)
                    let components = calendar.dateComponents( [.month, .day, .hour, .minute],
                                                              from: earlyDate!)
                    let content = UNMutableNotificationContent()
                    content.title = "Заканчивается срок у задачи:"
                    content.body = data.checklistItems[index].title
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    
                    let itemID = data.checklistItems[index].itemID
                    let request = UNNotificationRequest(identifier: itemID, content: content, trigger: trigger)
                    
                    let center = UNUserNotificationCenter.current()
                    center.add(request)
                    
                }
            }
        }
    }
    
    func removeNotification(forItemAt index: Int, in data: Data){
        let itemID = data.checklistItems[index].itemID
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [itemID])
    }
    
}
