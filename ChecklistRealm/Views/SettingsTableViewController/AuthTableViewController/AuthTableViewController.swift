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
    
    @IBOutlet weak var usingPasscodeSwitch: UISwitch!
    @IBOutlet weak var changePasscodeCell: UITableViewCell!
    @IBOutlet weak var usingOfBiometricsCell: UITableViewCell!
    @IBOutlet weak var usingOfBiometricSwitch: UISwitch!
    
    weak var delegate: AuthTableViewControllerDelegate?

    let configuration: PasscodeLockConfigurationType
    var additionalSettingVisible: Bool
    
    init(configuration: PasscodeLockConfigurationType) {
        
        self.configuration = configuration
        self.additionalSettingVisible = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        let repository = UserDefaultsPasscodeRepository()
        configuration = PasscodeLockConfiguration(repository: repository)
        additionalSettingVisible = configuration.repository.hasPasscode
        
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePasscodeView()
        
    }
    
    func updatePasscodeView() {
        
        usingPasscodeSwitch.isOn = configuration.repository.hasPasscode
        usingOfBiometricSwitch.isOn = UserDefaults.standard.bool(forKey: "isTouchIDAllowed")
        
        if usingPasscodeSwitch.isOn {

            showAdditionalSettings()

        } else {
            hideAdditionalSettings()
        }
    
}
    
    @IBAction func done(_ sender: UIBarButtonItem) {

        delegate?.authTableViewControllerDidFinishEditingSettings(self)
    }
    
    @IBAction func usingPasscodeSwitchAction(_ sender: UISwitch) {
        
        let passcodeVC: PasscodeLockViewController
        
        if usingPasscodeSwitch.isOn {

            passcodeVC = PasscodeLockViewController(state: .setPasscode, configuration: configuration)
            passcodeVC.successCallback = { lock in
                self.updatePasscodeView()
            }
            
        } else {
            passcodeVC = PasscodeLockViewController(state: .removePasscode, configuration: configuration)
            
            passcodeVC.successCallback = { lock in
                lock.repository.deletePasscode()
                UserDefaults.standard.set(false, forKey: "isTouchIDAllowed")
                DispatchQueue.main.async {
                    self.updatePasscodeView()
                }
            }
            
            
        }
        present(passcodeVC, animated: true, completion: nil)
    }
    
    func showAdditionalSettings(){
        if !additionalSettingVisible {
            additionalSettingVisible = true
            tableView.insertRows(at: [IndexPath(row: 1, section: 0),IndexPath(row: 2, section: 0)], with: .fade)
            usingOfBiometricSwitch.isOn = UserDefaults.standard.bool(forKey: "isTouchIDAllowed")
        }
    }
    func hideAdditionalSettings(){
        if additionalSettingVisible {
            additionalSettingVisible = false
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: 1, section: 0),IndexPath(row: 2, section: 0)], with: .fade)
            tableView.endUpdates()
        }
    }
    @IBAction func usingOfBiometricsSwitchAction(_ sender: UISwitch) {
        if usingOfBiometricSwitch.isOn {
            UserDefaults.standard.set(true, forKey: "isTouchIDAllowed")
        } else {
            UserDefaults.standard.set(false, forKey: "isTouchIDAllowed")
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if additionalSettingVisible {
                return 3
            } else {
                return 1
            }
        } else {
            return super.tableView(tableView,
                                   numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            // for changePasscodeCell and usingOfBiometricsCell
            if indexPath.row == 1 || indexPath.row == 2{
                return 44
            }
            
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            // for changePasscodeCell
            if indexPath.row == 1 {
                return changePasscodeCell
            }
            
            // for usingOfBiometricsCell
            if indexPath.row == 2 {
                return usingOfBiometricsCell
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
        if (indexPath.section == 0 && indexPath.row == 1) || (indexPath.section == 1 && indexPath.row == 0) {
            return indexPath
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 1 {
            self.tableView.deselectRow(at: indexPath, animated: true)
            let repo = UserDefaultsPasscodeRepository()
            let config = PasscodeLockConfiguration(repository: repo)
            
            let passcodeLock = PasscodeLockViewController(state: .changePasscode, configuration: config)
            
            present(passcodeLock, animated: true, completion: nil)
        }
    }

}
