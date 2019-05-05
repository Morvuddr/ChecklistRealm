//
//  Data.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    
    var checklistItems = List<ChecklistItem>()
    
}
