//
//  UserDefaultsPasscodeRepository.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 26/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    fileprivate let passcodeKey = "passcode.lock.passcode"
    
    fileprivate lazy var defaults: UserDefaults = {
        
        return UserDefaults.standard
    }()
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        
        return defaults.value(forKey: passcodeKey) as? [String] ?? nil
    }
    
    func savePasscode(_ passcode: [String]) {
        
        defaults.set(passcode, forKey: passcodeKey)
        defaults.synchronize()
    }
    
    func deletePasscode() {
        
        defaults.removeObject(forKey: passcodeKey)
        defaults.synchronize()
    }
}