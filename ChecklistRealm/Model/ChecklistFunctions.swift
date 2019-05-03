//
//  ChecklistFunctions.swift
//  Checklist
//
//  Created by Игорь Бопп on 26/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import Foundation

class ChecklistFunctions {
    
    
    static func createChecklistItem(_ checklistItem: ChecklistItem){

            Data.checklistItems.insert(checklistItem, at: 0)
       
    }
    
    static func readChecklist(completion: @escaping () -> ()){
        
        
    }
    
    static func updateChecklistItem(at index: Int, title: String, additionalInfo: String){
        
        Data.checklistItems[index].title = title
        Data.checklistItems[index].additionalInfo = additionalInfo
        
    }
    
    static func deleteChecklistItem(at index: Int){
        

                Data.checklistItems.remove(at: index)
        
        
    }
    
    static func sortChecklistItems(){
        
        Data.checklistItems.sort(){
            $0.date > $1.date
        }
        
        Data.checklistItems.sort() {
            !$0.checked && $1.checked
        }
        
    }
    
    static func toggleChecked(at index: Int){
        Data.checklistItems[index].checked = !Data.checklistItems[index].checked
    }
    
    // MARK: - Data update every 30 seconds
    
    static func startTimer(){
        _ = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { (Timer) in
            
            sortChecklistItems()
            
        }
    }
    
    
}
