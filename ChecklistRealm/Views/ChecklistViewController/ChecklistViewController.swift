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
    var data: ChecklistData?
    var notificationToken: NotificationToken?
    private let firstLaunch = "firstLaunch"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureChecklistTableView()
        
        let realm = ChecklistFunctions.shared.realm
        
        if !NSUbiquitousKeyValueStore.default.bool(forKey: firstLaunch){
            
            ChecklistFunctions.shared.createData()
            NSUbiquitousKeyValueStore.default.set(true, forKey: firstLaunch)
            
        }
        
        if NSUbiquitousKeyValueStore.default.bool(forKey: "shouldRemind") == false && NSUbiquitousKeyValueStore.default.longLong(forKey: "remindHours") == 0 {
            
            NSUbiquitousKeyValueStore.default.set(true, forKey: "shouldRemind")
            NSUbiquitousKeyValueStore.default.set(1, forKey: "remindHours")
            NSUbiquitousKeyValueStore.default.set(0, forKey: "remindMinutes")
        
        }
        
        
        data = realm.objects(ChecklistData.self).first!
        ChecklistFunctions.shared.sortChecklistItems(in: data!)
        
        let secondTabNavController = self.tabBarController?.viewControllers![1] as! UINavigationController
        let secondTab = secondTabNavController.topViewController as! SettingsTableViewController
        secondTab.data = data
        
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
        
        let viewController = AddItemTableViewController.getInstance() as! AddItemTableViewController
        viewController.delegate = self
        viewController.data = data
        
        if let itemToEdit = itemToEdit {
            viewController.itemToEdit = itemToEdit
            viewController.indexToEdit = indexToEdit
        }
        self.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func addNewChecklistItem() {
        showAddNewItemTableViewController()
    }
    
}

extension ChecklistViewController: UITableViewDelegate, UITableViewDataSource, ChecklistTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data!.checklistItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChecklistTableViewCell.identifier) as! ChecklistTableViewCell
        cell.delegate = self
        cell.setup(data!.checklistItems[indexPath.row], indexPath.row)
        
        return cell
    }
    

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { (contextualAction, view, actionPerfomed: @escaping (Bool) -> ()) in
            
            let alert = UIAlertController(title: "Удаление задачи", message: "Вы уверены, что хотите удалить задачу: \(self.data!.checklistItems[indexPath.row].title) ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: { (alertAction) in
                actionPerfomed(false)
            }))
            alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { (alertAction) in
                // Perform delete
                ChecklistFunctions.shared.removeNotification(forItemAt: indexPath.row, in: self.data!)
                ChecklistFunctions.shared.deleteChecklistItem(at: indexPath.row, in: self.data!)
                actionPerfomed(false)
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
        
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func checkmarkButtonTapped(at checklistItem: ChecklistItem) {
        let index = (data?.checklistItems.firstIndex(of: checklistItem))!
        ChecklistFunctions.shared.toggleChecked(at: index, in: data!)
        
        if (data?.checklistItems[index].checked)! {
            ChecklistFunctions.shared.removeNotification(forItemAt: index, in: data!)
        } else {
            ChecklistFunctions.shared.scheduleNotification(forItemAt: index, in: data!)
        }
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
        self.hidesBottomBarWhenPushed = false
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishAdding item: ChecklistItem) {
        
        ChecklistFunctions.shared.createChecklistItem(data!, item)
        
        ChecklistFunctions.shared.scheduleNotification(forItemAt: 0, in: data!)
        
        self.hidesBottomBarWhenPushed = false
        navigationController?.popViewController(animated:true)
    }
    
    func addItemTableViewController(_ controller: AddItemTableViewController,
                                    didFinishEditing item: ChecklistItem, _ indexToEdit: Int) {
        
        ChecklistFunctions.shared.scheduleNotification(forItemAt: indexToEdit, in: data!)
        
        self.hidesBottomBarWhenPushed = false
        navigationController?.popViewController(animated:true)
    }
    
}
