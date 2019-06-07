//
//  UserDefaultsPasscodeRepository.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 26/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

class UserDefaultsPasscodeRepository: PasscodeRepositoryType {
    
    fileprivate let passcodeKey = "passcode"
    
    var hasPasscode: Bool {
        
        if passcode != nil {
            return true
        }
        
        return false
    }
    
    var passcode: [String]? {
        
        return NSUbiquitousKeyValueStore.default.array(forKey: passcodeKey) as? [String] ?? nil
    }
    
    func savePasscode(_ passcode: [String]) {
        
        NSUbiquitousKeyValueStore.default.set(passcode, forKey: passcodeKey)
        
    }
    
    func deletePasscode() {
        
        NSUbiquitousKeyValueStore.default.removeObject(forKey: passcodeKey)
        
    }
}
