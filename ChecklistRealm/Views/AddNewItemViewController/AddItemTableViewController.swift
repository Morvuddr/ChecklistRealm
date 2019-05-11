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

protocol AddItemTableViewControllerDelegate: class {
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishAdding item: ChecklistItem)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishEditing item: ChecklistItem)
}


class AddItemTableViewController: UITableViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
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
    let annotation = MKPointAnnotation()
    
    var currentRowHeight: CGFloat = 75 {
        didSet{
            if oldValue - currentRowHeight > 100{
                DispatchQueue.main.async {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 3), at: .bottom, animated: false)
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
            dateLabel.text = item.dateStr
            doneBarItem.isEnabled = true
            location = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
            centerViewOnItemLocation()
        } else {
            dateLabel.text = createDate()
            checkLocationServices()
            centerViewOnItemLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        mapView.removeAnnotation(annotation)
        delegate?.addItemTableViewControllerDidCancel(self)
    }
    @IBAction func done() {
        mapView.removeAnnotation(annotation)
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
        if indexPath.section == 3 {
            
            let rowHeight = additionalInfoTextView.text.heightWithConstrainedWidth(width: tableView.frame.width - 32, font: UIFont.systemFont(ofSize: 18)) + 47
            currentRowHeight = rowHeight
            return rowHeight
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
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
        if newText.isEmpty || titleTextField.text?.isEmpty ?? true {
            doneBarItem.isEnabled = false
        } else {
            doneBarItem.isEnabled = true
        }
        return newText.count <= maxLength
    }
    
}

extension AddItemTableViewController {
    
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
            
            if !UserDefaults.standard.bool(forKey: "locationOff"){
            let alert = UIAlertController(title: "Службы геолокации отключены", message: "Пожалуйста, перейдите в Настройки, чтобы изменить это.", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alert.addAction(okButton)
            UserDefaults.standard.set(true, forKey: "locationOff")
            self.present(alert, animated: true)
            }
        }
    }
    
    func setupLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            
            if !UserDefaults.standard.bool(forKey: "locationRestricted"){
            
            let alert = UIAlertController(title: "Использование геопозиции ограничено", message: "Доступ к геопозиции ограничен и локация не может быть получена", preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "Понятно", style: .default, handler: nil)
            alert.addAction(okButton)
            
            UserDefaults.standard.set(true, forKey: "locationRestricted")
            self.present(alert, animated: true)
                
            }
            
        case .denied:
            
            if !UserDefaults.standard.bool(forKey: "locationDenied"){
            
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
            
            UserDefaults.standard.set(true, forKey: "locationDenied")
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
    
}

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return boundingBox.height
    }
}

@IBDesignable class ZeroPaddingTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
