//
//  SettingsTableViewController.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 13/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    var data: ChecklistData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return super.tableView(tableView, numberOfRowsInSection: section)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return super.tableView(tableView, cellForRowAt: indexPath)
        
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 0 && indexPath.row == 0) || (indexPath.section == 1 && indexPath.row == 0) {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 && indexPath.row == 0 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            let viewController = NotificationsTableViewController.getInstance() as! NotificationsTableViewController
            viewController.delegate = self
            viewController.data = self.data
            
            self.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
        if indexPath.section == 1 && indexPath.row == 0 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            
            let viewController = AuthTableViewController.getInstance() as! AuthTableViewController
            viewController.delegate = self
            
            self.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension SettingsTableViewController: AuthTableViewControllerDelegate, NotificationsTableViewControllerDelegate {
    func authTableViewControllerDidFinishEditingSettings(_ controller: AuthTableViewController) {
        self.hidesBottomBarWhenPushed = false
        navigationController?.popViewController(animated: true)
    }
    func notificationsTableViewControllerDidFinishEditingSettings (_ controller: NotificationsTableViewController) {
        self.hidesBottomBarWhenPushed = false
        navigationController?.popViewController(animated: true)
    }
}
