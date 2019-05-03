//
//  TaskItem.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject {
    
    var title: String
    var date: String
    var additionalInfo: String?
    var checked: Bool
    
    
    init(_ title: String, _ date: String, _ additionalInfo: String? = nil, _ checked: Bool = false) {
        self.title = title
        self.date = date
        self.additionalInfo = additionalInfo
        self.checked = checked
        
    }
    
}
