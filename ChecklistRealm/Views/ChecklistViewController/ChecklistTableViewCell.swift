//
//  ChecklistTableViewCell.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class ChecklistTableViewCell: UITableViewCell {

    @IBOutlet weak var checklistTitle: UILabel!
    @IBOutlet weak var checkmark: UILabel!
    @IBOutlet weak var checklistAdditionalInfo: UILabel!
    @IBOutlet weak var checklistDate: UILabel!
    
    func setup(_ checklistItem: ChecklistItem){
        checklistTitle.text = checklistItem.title
        checklistDate.text = checklistItem.date
        if let additionalInfo = checklistItem.additionalInfo {
            checklistAdditionalInfo.text = additionalInfo
        }
        if checklistItem.checked {
            checkmark.text = "✔︎"
        } else {
            checkmark.text = ""
        }
    }
    
}

extension UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}
