//
//  SettingsTableViewController.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 13/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var remindTimeLabel: UILabel!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var data: Data?
    var dateCellVisible = false
    var datePickerVisible = false
    var shouldRemind = true {
        didSet {
            if shouldRemind != UserDefaults.standard.bool(forKey: "shouldRemind"){
                enableButtons()
            }
            disableButtons()
        }
    }
    var remindHours: Int = 1 {
        didSet {
            if remindHours != UserDefaults.standard.integer(forKey: "remindHours"){
                enableButtons()
            }
            disableButtons()
        }
    }
    var remindMinutes: Int = 0 {
        didSet {
            if remindMinutes != UserDefaults.standard.integer(forKey: "remindMinutes"){
                enableButtons()
            }
            disableButtons()
        }
    }
    
    func enableButtons() {
        tabBarController?.tabBar.items![0].isEnabled = false
        saveButton.isEnabled = true
        cancelButton.isEnabled = true
    }
    
    func disableButtons() {
        if shouldRemind == UserDefaults.standard.bool(forKey: "shouldRemind") &&
            remindHours == UserDefaults.standard.integer(forKey: "remindHours") &&
            remindMinutes == UserDefaults.standard.integer(forKey: "remindMinutes"){
            saveButton.isEnabled = false
            cancelButton.isEnabled = false
            tabBarController?.tabBar.items![0].isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        configureTableViewConroller()
        
    }
    
    func configureTableViewConroller() {
        
        shouldRemind = UserDefaults.standard.bool(forKey: "shouldRemind")
        remindHours = UserDefaults.standard.integer(forKey: "remindHours")
        remindMinutes = UserDefaults.standard.integer(forKey: "remindMinutes")
        
        if UserDefaults.standard.bool(forKey: "shouldRemind") {
            shouldRemindSwitch.isOn = true
            showDateCell()
        } else {
            shouldRemindSwitch.isOn = false
            hideDateCell()
        }
        
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(shouldRemind, forKey: "shouldRemind")
        UserDefaults.standard.set(remindHours, forKey: "remindHours")
        UserDefaults.standard.set(remindMinutes, forKey: "remindMinutes")
        hideDatePicker()
        disableButtons()
        ChecklistFunctions.shared.updateNotifications(in: data!)
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        
        configureTableViewConroller()
        
    }
    
    func configureRemindTimeLabel(_ remindHours: Int, _ remindMinutes: Int){
        
        switch remindHours {
        case 1,21:
            remindTimeLabel.text = "\(remindHours) час \(remindMinutes) минут"
        case 2,3,4,22,23:
            remindTimeLabel.text = "\(remindHours) часа \(remindMinutes) минут"
        default:
            remindTimeLabel.text = "\(remindHours) часов \(remindMinutes) минут"
        }
        
    }
    
    @IBAction func shouldRemindAction(_ sender: UISwitch) {
  
        if shouldRemindSwitch.isOn {
            showDateCell()
        } else {
            if datePickerVisible {
                hideDatePicker()
            }
            hideDateCell()
        }
    }
    
    func showDateCell(){
        
        dateCellVisible = true
        shouldRemind = true
        tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .fade)
        configureRemindTimeLabel(remindHours, remindMinutes)
        
    }
    
    func hideDateCell(){
        if dateCellVisible {
            if datePickerVisible {
                hideDatePicker()
            }
            dateCellVisible = false
            shouldRemind = false
            remindHours = 1
            remindMinutes = 0
            let indexPathDateRow = IndexPath(row: 1, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPathDateRow], with: .fade)
            tableView.endUpdates()
        }
    }
    
    func showDatePicker(){
        datePickerVisible = true
        tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        let calendar = Calendar(identifier: .gregorian)
        let components = DateComponents(year: 2019, month: 05, day: 13, hour: remindHours, minute: remindMinutes, second: 0)
        datePicker.setDate(calendar.date(from: components)!, animated: false)
    }
    
    func hideDatePicker(){
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = IndexPath(row: 2, section: 0)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPathDateRow], with: .fade)
            tableView.endUpdates()
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: datePicker.date)
        remindHours = components.hour!
        remindMinutes = components.minute!
        configureRemindTimeLabel(remindHours, remindMinutes)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && dateCellVisible {
            if datePickerVisible {
                return 3
            }
            return 2
        } else {
            return super.tableView(tableView,
                                   numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            // for dateCell
            if indexPath.row == 1 {
                return 44
            }
            
            // for datePickerCell
            if indexPath.row == 2 {
                return 217
            }
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            // for dateCell
            if indexPath.row == 1 {
                return dateCell
            }
            
            // for datePickerCell
            if indexPath.row == 2 {
                return datePickerCell
            }
            
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
 
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 0 && (indexPath.row == 1 || indexPath.row == 2) {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 && indexPath.row == 1 {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.row == 1 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
}
