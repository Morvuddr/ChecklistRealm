//
//  TaskItem.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class ChecklistItem: Object {
    
    dynamic var itemID: String = ""
    dynamic var title: String = ""
    dynamic var date: Date = Date()
    dynamic var dateStr: String = ""
    dynamic var additionalInfo: String? = nil
    dynamic var checked: Bool = false
    dynamic var latitude: Double = 0
    dynamic var longitude: Double = 0
    dynamic var dueDate: Date? = nil
    dynamic var shouldRemind = false
    
    convenience init(_ title: String, _ date: Date, _ dateStr: String, _ additionalInfo: String? = nil, _ checked: Bool = false, _ latitude: Double = 0, _ longitude: Double = 0, _ dueDate: Date? = nil, _ shouldRemind: Bool = false) {
        self.init()
        self.itemID = UUID().uuidString
        self.title = title
        self.date = date
        self.dateStr = dateStr
        self.additionalInfo = additionalInfo
        self.checked = checked
        self.latitude = latitude
        self.longitude = longitude
        self.dueDate = dueDate
        self.shouldRemind = shouldRemind
    }
    
}
