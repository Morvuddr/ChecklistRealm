//
//  ChecklistTableViewCell.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

protocol ChecklistTableViewCellDelegate: class {
    func checkmarkButtonTapped(in index: Int)
}

class ChecklistTableViewCell: UITableViewCell {

    @IBOutlet weak var checklistTitle: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!
    @IBOutlet weak var checklistAdditionalInfo: UILabel!
    @IBOutlet weak var checklistDate: UILabel!
    
    weak var delegate: ChecklistTableViewCellDelegate?
    
    func setup(_ checklistItem: ChecklistItem, _ index: Int){
        checkmarkButton.tag = index
        self.checkmarkButton.addTarget(self, action: #selector(checkmarkButtonTapped(_:)), for: .touchUpInside)
        checklistTitle.text = checklistItem.title
        checklistDate.text = ChecklistFunctions.shared.createStringFromDate(checklistItem.date)
        if let additionalInfo = checklistItem.additionalInfo {
            checklistAdditionalInfo.text = additionalInfo
        }
        if checklistItem.checked {
            checkmarkButton.isSelected = true
            checklistTitle.textColor = UIColor.gray
        } else {
            checkmarkButton.isSelected = false
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
    @IBAction func checkmarkButtonTapped(_ sender: UIButton){
        
        if let delegate = delegate {
            delegate.checkmarkButtonTapped(in: checkmarkButton.tag)
        }
        
    }
    
}

extension UITableViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}
