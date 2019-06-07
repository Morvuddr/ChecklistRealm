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
    
    var currentSchemaVersion: UInt64 = 3
    
    
    func createData(){
        
        let data = ChecklistData(id: UUID().uuidString)
        
        do {
            
            try realm.write{
                realm.add(data)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func createChecklistItem(_ data: ChecklistData,_ checklistItem: ChecklistItem){
        
        do {
            
            try realm.write{
                data.checklistItems.insert(checklistItem, at: 0)
            }
            
        } catch {
            print(error)
        }
        
    }
    
    func updateChecklistItem(at index: Int, title: String, additionalInfo: String, dueDate: Date?, shouldRemind: Bool, in data: ChecklistData){
        
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
    
    func deleteChecklistItem(at index: Int, in data: ChecklistData){
        
        do {
            try realm.write{
                
                data.checklistItems[index].isDeleted = true
                data.checklistItems.remove(at: index)
                
                
            }
        } catch {
            print(error)
        }
        
    }
    
    func sortChecklistItems(in data: ChecklistData){
        
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
    
    func toggleChecked(at index: Int, in data: ChecklistData){
        
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
                                            
                                            if oldSchemaVersion < 3{
                                                self.migrateFrom2To3(with: migration)
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
    
    func migrateFrom2To3(with migration: Migration){
        migration.enumerateObjects(ofType: ChecklistItem.className()) { (oldChecklistItem, newChecklistItem) in
            let _ = oldChecklistItem?["dateStr"] as! String
            newChecklistItem?["isDeleted"] = false
            newChecklistItem?["longitude"] = Double(0)
        }
        migration.enumerateObjects(ofType: "Data") { (oldData, newData) in
//            newData?["isDeleted"] = false
//            newData?["dataID"] = UUID().uuidString
            let newChecklistData = migration.create(ChecklistData.className())
            newChecklistData["isDeleted"] = false
            newChecklistData["dataID"] = UUID().uuidString
            
            if let oldChecklistItems = oldData!["checklistItems"] as? List<MigrationObject>,
                let newChecklistItems = newChecklistData["checklistItems"] as? List<MigrationObject>{
                
                for oldChecklistItem in oldChecklistItems {
                    let newChecklistItem = migration.create(ChecklistItem.className())
                    newChecklistItem["itemID"] = oldChecklistItem["itemID"]
                    newChecklistItem["title"] = oldChecklistItem["title"]
                    newChecklistItem["date"] = oldChecklistItem["date"]
                    newChecklistItem["additionalInfo"] = oldChecklistItem["additionalInfo"]
                    newChecklistItem["checked"] = oldChecklistItem["checked"]
                    newChecklistItem["latitude"] = oldChecklistItem["latitude"]
                    newChecklistItem["longitude"] = oldChecklistItem["longitude"]
                    newChecklistItem["dueDate"] = oldChecklistItem["dueDate"]
                    newChecklistItem["shouldRemind"] = oldChecklistItem["shouldRemind"]
                    newChecklistItem["isDeleted"] = oldChecklistItem["isDeleted"]
                    
                    newChecklistItems.append(newChecklistItem)
                    migration.delete(oldChecklistItem)
                }
            }
        }
        migration.deleteData(forType: "Data")
    }
    
    // MARK: - Notifications
    
    func scheduleNotification(forItemAt index: Int, in data: ChecklistData) {
        removeNotification(forItemAt: index, in: data)
        if data.checklistItems[index].shouldRemind {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
                // do nothing
            }
            
            if let dueDate = data.checklistItems[index].dueDate{
                if dueDate.timeIntervalSinceNow > 0 && data.checklistItems[index].checked == false && NSUbiquitousKeyValueStore.default.bool(forKey: "shouldRemind"){
                    
                    let calendar = Calendar(identifier: .gregorian)
                    let diff = calendar.dateComponents([.hour, .minute, .second], from: Date(), to: dueDate)
                    
                    let remindHours = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "remindHours"))
                    let remindMinutes = Int(NSUbiquitousKeyValueStore.default.longLong(forKey: "remindMinutes"))
                    
                    let firstSituation = ((remindHours == 0 && remindMinutes > 0) && (diff.minute! > remindMinutes || (diff.minute! == remindMinutes || diff.second! > 0)))
                    
                    let secondSituation = ((remindHours > 0 && remindMinutes == 0) && (diff.hour! > remindHours || (diff.hour! == remindHours && diff.second! > 0)))
                    
                    let thirdSituation = ((remindHours > 0 && remindMinutes > 0) && (diff.hour! > remindHours || (diff.hour! == remindHours && diff.minute! > remindMinutes) || (diff.hour! == remindHours && diff.minute! == remindMinutes && diff.second! > 0)))
                    
                    let fourthSituation = (remindHours == 0 && remindMinutes == 0)
                    
                    if firstSituation || secondSituation || thirdSituation || fourthSituation {
                        
                        var earlyDate = Calendar.current.date(byAdding: .hour, value: -remindHours, to: dueDate)
                        earlyDate = Calendar.current.date(byAdding: .minute, value: -remindMinutes, to: earlyDate!)
                        
                        let components = calendar.dateComponents( [.month, .day, .hour, .minute],
                                                                  from: earlyDate!)
                        let content = UNMutableNotificationContent()
                        content.title = "Заканчивается срок у задачи:"
                        content.body = data.checklistItems[index].title
                        content.sound = UNNotificationSound.default
                        
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        
                        let itemID = data.checklistItems[index].itemID
                        let request = UNNotificationRequest(identifier: itemID, content: content, trigger: trigger)
                        
                        
                        center.add(request)
                    }
                }
            }
        }
    }
    
    func removeNotification(forItemAt index: Int, in data: ChecklistData){
        let itemID = data.checklistItems[index].itemID
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [itemID])
    }
    
    func updateNotifications(in data: ChecklistData){
        for index in 0 ..< data.checklistItems.count{
            if NSUbiquitousKeyValueStore.default.bool(forKey: "shouldRemind") {
                scheduleNotification(forItemAt: index, in: data)
            } else {
                removeNotification(forItemAt: index, in: data)
            }
        }
    }
    
    // MARK: - Returns the date in string format
    
    func createStringFromDate(_ date: Date) -> String {
        
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        
        // get the date time String from the date object
        return formatter.string(from: date)
    }
    
}
