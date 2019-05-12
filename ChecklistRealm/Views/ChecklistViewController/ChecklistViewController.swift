//
//  ViewController.swift
//  Checklist
//
//  Created by Игорь Бопп on 25/04/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import RealmSwift

class ChecklistViewController: UIViewController {
    
    @IBOutlet weak var checklistTableView: UITableView!
    var data: Data?
    var notificationToken: NotificationToken?
    private let firstLaunch = "firstLaunch"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureChecklistTableView()
        
        let realm = ChecklistFunctions.shared.realm
        
        if !UserDefaults.standard.bool(forKey: firstLaunch){
            
            ChecklistFunctions.shared.createData()
            
            UserDefaults.standard.set(true, forKey: firstLaunch)
        }
        
        data = realm.objects(Data.self).first!
        ChecklistFunctions.shared.sortChecklistItems(in: data!)
        
        notificationToken = data?.checklistItems.observe { [weak self] (changes) in
            guard let tableView = self?.checklistTableView else { return }
            switch changes {
            case .initial:
                
                tableView.reloadData()
                
            case .update(_, let deletions, let insertions, let modifications):
                
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .none)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
    }
    
    
    func configureChecklistTableView(){
        
        checklistTableView.delegate = self
        checklistTableView.dataSource = self
        checklistTableView.estimatedRowHeight = 0
        
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func showAddNewItemTableViewController(_ itemToEdit: ChecklistItem? = nil, _ indexToEdit: Int? = nil){
        // Returns the initial view controller on a storyboard
        let storyboard = UIStoryboard(name: String(describing: AddItemTableViewController.self), bundle: nil)
        let viewController = storyboard.instantiateInitialViewController() as! AddItemTableViewController
        viewController.delegate = self
        viewController.data = data
        
        if let itemToEdit = itemToEdit {
            viewController.itemToEdit = itemToEdit
            viewController.indexToEdit = indexToEdit
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addNewChecklistItem() {
        showAddNewItemTableViewController()
    }
    
}

extension ChecklistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data!.checklistItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChecklistTableViewCell.identifier) as! ChecklistTableViewCell
        
        cell.setup(data!.checklistItems[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        ChecklistFunctions.shared.deleteChecklistItem(at: indexPath.row, in: data!)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        ChecklistFunctions.shared.toggleChecked(at: indexPath.row, in: data!)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let itemToEdit = data!.checklistItems[indexPath.row]
        
        showAddNewItemTableViewController(itemToEdit, indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}

extension ChecklistViewController: AddItemTableViewControllerDelegate {
    
    func addItemTableViewControllerDidCancel(_ controller: AddItemTableViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishAdding item: ChecklistItem) {
        
        ChecklistFunctions.shared.createChecklistItem(data!, item)
        
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishEditing item: ChecklistItem) {
            navigationController?.popViewController(animated:true)
    }
    
}
