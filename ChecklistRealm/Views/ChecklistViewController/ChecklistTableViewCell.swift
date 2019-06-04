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
        checklistDate.text = ChecklistFunctions.shared.createStringFromDate(checklistItem.date)
        if let additionalInfo = checklistItem.additionalInfo {
            checklistAdditionalInfo.text = additionalInfo
        }
        if checklistItem.checked {
            checkmark.text = "✔︎"
            checklistTitle.textColor = UIColor.black
        } else {
            checkmark.text = ""
            if let dueDate = checklistItem.dueDate {
                if dueDate.timeIntervalSinceNow < 0 {
                    checklistTitle.textColor = UIColor.red
                } else {
                    checklistTitle.textColor = UIColor.black
                }
            } else {
                checklistTitle.textColor = UIColor.black
            }
        }
    }
    
}

extension UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}
