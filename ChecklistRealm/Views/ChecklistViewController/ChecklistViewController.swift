//
//  ViewController.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var checklistTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureChecklistTableView()
//        ChecklistFunctions.readChecklist(){
//            ChecklistFunctions.sortChecklistItems()
//            self.checklistTableView.reloadData()
//        }
        
        //ChecklistFunctions.startTimer()
        
    }
    
    func configureChecklistTableView(){
        
        checklistTableView.delegate = self
        checklistTableView.dataSource = self
        
        checklistTableView.rowHeight = UITableView.automaticDimension
        checklistTableView.estimatedRowHeight = 100
        
    }
    
    func showAddNewItemTableViewController(_ itemToEdit: ChecklistItem? = nil){
        // Returns the initial view controller on a storyboard
        let storyboard = UIStoryboard(name: String(describing: AddItemTableViewController.self), bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! AddItemTableViewController
        viewController.delegate = self
        
        if let itemToEdit = itemToEdit {
            viewController.itemToEdit = itemToEdit
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addNewChecklistItem() {
        showAddNewItemTableViewController()
    }
    
}

extension ChecklistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Data.checklistItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChecklistTableViewCell.identifier) as! ChecklistTableViewCell
        
        cell.setup(Data.checklistItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        ChecklistFunctions.deleteChecklistItem(at: indexPath.row)
        checklistTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChecklistTableViewCell {
            ChecklistFunctions.toggleChecked(at: indexPath.row)
            cell.setup(Data.checklistItems[indexPath.row])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let itemToEdit = Data.checklistItems[indexPath.row]
        
        showAddNewItemTableViewController(itemToEdit)
    }
    
}

extension ChecklistViewController: AddItemTableViewControllerDelegate {
    
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishAdding item: ChecklistItem) {
        
        ChecklistFunctions.createChecklistItem(item)
        checklistTableView.beginUpdates()
        checklistTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        checklistTableView.endUpdates()
        
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishEditing item: ChecklistItem) {
        if let index = Data.checklistItems.firstIndex(of: item) {

            let indexPath = IndexPath(row: index, section: 0)
            let cell = checklistTableView.cellForRow(at: indexPath) as! ChecklistTableViewCell
            cell.setup(item)
            
            navigationController?.popViewController(animated:true)
        }
    }
    
}
