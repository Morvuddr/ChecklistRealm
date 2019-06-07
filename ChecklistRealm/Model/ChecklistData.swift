//
//  ChecklistData.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import RealmSwift

class ChecklistData: Object {
    
    @objc dynamic var dataID: String = ""
    var checklistItems = List<ChecklistItem>()
    @objc dynamic var isDeleted = false
    
    override class func primaryKey() -> String? {
        return "dataID"
    }
    
    convenience init(id: String) {
        self.init()
        self.dataID = id
        
    }

}

extension ChecklistData: CKRecordRecoverable {
    
}

extension ChecklistData: CKRecordConvertible {
    
}
