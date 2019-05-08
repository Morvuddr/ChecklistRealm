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

protocol AddItemTableViewControllerDelegate: class {
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishAdding item: ChecklistItem)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishEditing item: ChecklistItem)
}


class AddItemTableViewController: UITableViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    var currentDate: Date?
    @IBOutlet weak var doneBarItem: UIBarButtonItem!
    
    var itemToEdit: ChecklistItem?
    var indexToEdit: Int?
    
    weak var delegate: AddItemTableViewControllerDelegate?
    var data: Data?
    
    let locationManager = CLLocationManager()
    var location = CLLocationCoordinate2D(latitude: CLLocationDegrees(0), longitude: CLLocationDegrees(0))
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let item = itemToEdit {
            title = "Подробно"
            titleTextField.text = item.title
            additionalInfoTextView.text = item.additionalInfo
            dateLabel.text = item.dateStr
            doneBarItem.isEnabled = true
            location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
        } else {
            dateLabel.text = createDate()
            checkLocationServices()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.addItemTableViewControllerDidCancel(self)
    }
    @IBAction func done() {
        if let itemToEdit = itemToEdit {
            
            ChecklistFunctions.shared.updateChecklistItem(at: indexToEdit!, title: titleTextField.text!,additionalInfo: additionalInfoTextView.text, in: data!)
            delegate?.addItemTableViewController(self, didFinishEditing: itemToEdit)
            
        } else {
            let item = ChecklistItem(titleTextField.text!, currentDate!, dateLabel.text!, additionalInfoTextView.text, false, location.latitude, location.longitude)
            delegate?.addItemTableViewController(self, didFinishAdding: item)
        }
    }
    
    func createDate() -> String {
        // get the current date and time
        let currentDateTime = Date()
        self.currentDate = currentDateTime
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "ru_RU")
        
        // get the date time String from the date object
        return formatter.string(from: currentDateTime)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
}

extension AddItemTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let maxLength = 100
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty || additionalInfoTextView.text.isEmpty {
            doneBarItem.isEnabled = false
        } else {
            doneBarItem.isEnabled = true
        }
        return newText.count <= maxLength
    }
    
}

extension AddItemTableViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 1000
        let oldText = textView.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: text)
        if newText.isEmpty || titleTextField.text?.isEmpty ?? true {
            doneBarItem.isEnabled = false
        } else {
            doneBarItem.isEnabled = true
        }
        return newText.count <= maxLength
    }
    
}

extension AddItemTableViewController {
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            
        }
    }
    
    func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            break
        case .denied:
            // add alert
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            if let location = locationManager.location?.coordinate {
                self.location = location
                print(self.location)
            }
            break
        @unknown default:
            break
        }
    }
    
}
