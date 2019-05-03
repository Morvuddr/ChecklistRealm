//
//  AddItemTableViewController.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

protocol AddItemTableViewControllerDelegate: class {
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishAdding item: ChecklistItem)
    func addItemTableViewController(_ controller: AddItemTableViewController, didFinishEditing item: ChecklistItem)
}


class AddItemTableViewController: UITableViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doneBarItem: UIBarButtonItem!
    
    var itemToEdit: ChecklistItem?
    
    weak var delegate: AddItemTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let item = itemToEdit {
            title = "Подробно"
            titleTextField.text = item.title
            additionalInfoTextView.text = item.additionalInfo
            dateLabel.text = item.date
            doneBarItem.isEnabled = true
        } else {
            dateLabel.text = createDate()
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
            let index = Data.checklistItems.firstIndex(of: itemToEdit)!
            ChecklistFunctions.updateChecklistItem(at: index, title: titleTextField.text!,additionalInfo: additionalInfoTextView.text)
            delegate?.addItemTableViewController(self, didFinishEditing: itemToEdit)
            
        } else {
            let item = ChecklistItem(titleTextField.text!, dateLabel.text!, additionalInfoTextView.text)
            delegate?.addItemTableViewController(self, didFinishAdding: item)
        }
    }
    
    func createDate() -> String {
        // get the current date and time
        let currentDateTime = Date()
        
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
