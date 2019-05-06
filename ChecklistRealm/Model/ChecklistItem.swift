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
    
    dynamic var title: String = ""
    dynamic var date: Date = Date()
    dynamic var dateStr: String = ""
    dynamic var additionalInfo: String? = nil
    dynamic var checked: Bool = false
    
    
    convenience init(_ title: String, _ date: Date, _ dateStr: String, _ additionalInfo: String? = nil, _ checked: Bool = false) {
        self.init()
        self.title = title
        self.date = date
        self.dateStr = dateStr
        self.additionalInfo = additionalInfo
        self.checked = checked
        
    }
    
}
