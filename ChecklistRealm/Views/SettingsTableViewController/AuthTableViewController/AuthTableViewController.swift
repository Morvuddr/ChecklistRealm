//
//  AuthTableViewController.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 26/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

protocol AuthTableViewControllerDelegate: class {
    func authTableViewControllerDidFinishEditingSettings(_ controller: AuthTableViewController)
}

class AuthTableViewController: UITableViewController {
    
    
    weak var delegate: AuthTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        delegate?.authTableViewControllerDidFinishEditingSettings(self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

}
