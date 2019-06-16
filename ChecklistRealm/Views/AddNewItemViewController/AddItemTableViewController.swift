//
//  AddItemTableViewController.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation
import MapKit
import UserNotifications

protocol AddItemTableViewControllerDelegate: class {
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishAdding item: ChecklistItem)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishEditing item: ChecklistItem, _ indexToEdit: Int)
}


class AddItemTableViewController: UITableViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doneBarItem: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dateCell: UITableViewCell!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var itemToEdit: ChecklistItem?
    var indexToEdit: Int?
    
    weak var delegate: AddItemTableViewControllerDelegate?
    var data: ChecklistData?
    
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0))
    let annotation = MKPointAnnotation()
    
    var currentDate: Date?
    var dueDate: Date?
    var dateCellVisible: Bool = false
    var datePickerVisible: Bool = false
    
    var currentRowHeight: CGFloat = 75 {
        didSet{
            if oldValue - currentRowHeight > 100{
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 4), at: .bottom, animated: false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.rowHeight = UITableView.automaticDimension
        
        if let item = itemToEdit {
            title = "Подробно"
            titleTextField.text = item.title
            additionalInfoTextView.text = item.additionalInfo
            dateLabel.text = ChecklistFunctions.shared.createStringFromDate(item.date)
            doneBarItem.isEnabled = true
            location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            self.centerViewOnItemLocation()
            shouldRemindSwitch.isOn = item.shouldRemind
            if shouldRemindSwitch.isOn {
                dueDate = item.dueDate
                showDateCell()
            }
        } else {
            DispatchQueue.main.async {
                self.currentDate = Date()
                self.dateLabel.text = ChecklistFunctions.shared.createStringFromDate(self.currentDate!)
                self.checkLocationServices()
                self.centerViewOnItemLocation()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if itemToEdit == nil {
            titleTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        mapView.removeAnnotation(annotation)
        delegate?.addItemTableViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        mapView.removeAnnotation(annotation)
        
        let newTitle = titleTextField.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let newAdditionalInfo = additionalInfoTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if let itemToEdit = itemToEdit {
            
            ChecklistFunctions.shared.updateChecklistItem(at: indexToEdit!, title: newTitle, additionalInfo: newAdditionalInfo, dueDate: dueDate, shouldRemind: shouldRemindSwitch.isOn, in: data!)
            
            delegate?.addItemTableViewController(self, didFinishEditing: itemToEdit, indexToEdit!)
            
        } else {
            let item = ChecklistItem(newTitle, currentDate!, newAdditionalInfo, false, location.latitude, location.longitude, dueDate, shouldRemindSwitch.isOn)
            delegate?.addItemTableViewController(self, didFinishAdding: item)
        }
    }
    
    @IBAction func shouldRemindAction(_ sender: UISwitch) {
        titleTextField.resignFirstResponder()
        additionalInfoTextView.resignFirstResponder()
        if shouldRemindSwitch.isOn {
            showDateCell()
            DispatchQueue.main.async {
                let center = UNUserNotificationCenter.current()
                center.requestAuthorization(options: [.alert, .sound]) {
                    granted, error in
                    // do nothing
                }
            }
        } else {
            hideDateCell()
        }
    }
    
    func showDateCell(){
        
        dateCellVisible = true
        tableView.insertRows(at: [IndexPath(row: 1, section: 2)], with: .fade)
        
        if let dueDate = dueDate {
            
            dueDateLabel.text = ChecklistFunctions.shared.createStringFromDate(dueDate)
            
        } else {
            
            var dateComponent = DateComponents()
            dateComponent.hour = 1
            self.dueDate = Calendar.current.date(byAdding: dateComponent, to: Date())
            dueDateLabel.text = ChecklistFunctions.shared.createStringFromDate(dueDate!)
            
        }
        
    }
    
    func hideDateCell(){
        if datePickerVisible {
            hideDatePicker()
        }
        dateCellVisible = false
        dueDate = nil
        let indexPathDateRow = IndexPath(row: 1, section: 2)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPathDateRow], with: .fade)
        tableView.endUpdates()
    }
    
    func showDatePicker(){
        datePickerVisible = true
        tableView.insertRows(at: [IndexPath(row: 2, section: 2)], with: .fade)
        datePicker.setDate(dueDate!, animated: false)
    }
    
    func hideDatePicker(){
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = IndexPath(row: 2, section: 2)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPathDateRow], with: .fade)
            tableView.endUpdates()
        }
    }
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        dueDateLabel.text = ChecklistFunctions.shared.createStringFromDate(dueDate!)
    }
    
    // MARK:-  TableViewDelegate Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 4 && indexPath.row == 0 {
            let rowHeight = additionalInfoTextView.text.heightWithConstrainedWidth(width: tableView.frame.width - 32, font: UIFont.systemFont(ofSize: 18)) + 47
            currentRowHeight = rowHeight
            return rowHeight
        }
        
        if indexPath.section == 2 {
            
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
        if indexPath.section == 2 {
            
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 && dateCellVisible {
            if datePickerVisible {
                return 3
            }
            return 2
        } else {
            return super.tableView(tableView,
                                   numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 2 && (indexPath.row == 1 || indexPath.row == 2) {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        titleTextField.resignFirstResponder()
        additionalInfoTextView.resignFirstResponder()
        if indexPath.section == 2 && indexPath.row == 1 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
                tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 2 && indexPath.row == 1 {
            return indexPath
        }
        return nil
    }
    
}

// MARK:- Extensions

extension AddItemTableViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maxLength = 100
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty || newText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || additionalInfoTextView.text.isEmpty || additionalInfoTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            doneBarItem.isEnabled = false
        } else {
            doneBarItem.isEnabled = true
        }
        return newText.count <= maxLength
    }
    
}

extension AddItemTableViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        hideDatePicker()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 1000
        let oldText = textView.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: text)
        if newText.isEmpty || newText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty || titleTextField.text?.isEmpty ?? true || titleTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty ?? true {
            doneBarItem.isEnabled = false
        } else {
            doneBarItem.isEnabled = true
        }
        return newText.count <= maxLength
    }
    
}

extension AddItemTableViewController: CLLocationManagerDelegate {
    
    func centerViewOnItemLocation(){
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 150, longitudinalMeters: 150)
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
            if !NSUbiquitousKeyValueStore.default.bool(forKey: "locationOff"){
            let alert = UIAlertController(title: "Службы геолокации отключены", message: "Пожалуйста, перейдите в Настройки, чтобы изменить это.", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alert.addAction(okButton)
            NSUbiquitousKeyValueStore.default.set(true, forKey: "locationOff")
            self.present(alert, animated: true)
            }
        }
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            
            if !NSUbiquitousKeyValueStore.default.bool(forKey: "locationRestricted"){
            
            let alert = UIAlertController(title: "Использование геопозиции ограничено", message: "Доступ к геопозиции ограничен и локация не может быть получена", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alert.addAction(okButton)
            
            NSUbiquitousKeyValueStore.default.set(true, forKey: "locationRestricted")
            self.present(alert, animated: true)
                
            }
            
        case .denied:
            
            if !NSUbiquitousKeyValueStore.default.bool(forKey: "locationDenied"){
            
            let alert = UIAlertController(title: "Доступ к геопозиции запрещен", message: "Запрос на доступ к геопозиции был отклонен. Пожалуйста, перейдите в Настройки, чтобы изменить это.", preferredStyle: .alert)
            
            let goToSettingsAction = UIAlertAction(title: "Перейти в настройки", style: .default) {
                (action) in
                DispatchQueue.main.async{
                    let url = URL(string: UIApplication.openSettingsURLString)!
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            
            alert.addAction(goToSettingsAction)
            alert.addAction(cancelAction)
            
            NSUbiquitousKeyValueStore.default.set(true, forKey: "locationDenied")
            self.present(alert, animated: true)
                
            }
            
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            if let location = locationManager.location?.coordinate {
                self.location = location
            }
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus){
        DispatchQueue.main.async {
            self.checkLocationAuthorization()
            self.centerViewOnItemLocation()
        }
    }
    
}
