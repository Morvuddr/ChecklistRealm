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

class ChecklistFunctions {
    
    private init(){}
    static let shared = ChecklistFunctions()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var currentSchemaVersion: UInt64 = 1
    
    
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
    
    func updateChecklistItem(at index: Int, title: String, additionalInfo: String, in data: Data){
        
        do {
            try realm.write{
                
                data.checklistItems[index].title = title
                data.checklistItems[index].additionalInfo = additionalInfo
                
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
            
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    func migrateFrom0To1(with migration: Migration){
        migration.enumerateObjects(ofType: ChecklistItem.className()) { (_, newChecklistItem) in
            newChecklistItem?["latitude"] = Double(0)
            newChecklistItem?["longitude"] = Double(0)
        }
    }
    
}
