//
//  PasscodeLockConfiguration.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 26/05/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

struct PasscodeLockConfiguration: PasscodeLockConfigurationType {
    
    let repository: PasscodeRepositoryType
    let passcodeLength = 4
    var isTouchIDAllowed: Bool
    let shouldRequestTouchIDImmediately = true
    let maximumInccorectPasscodeAttempts = -1
    
    init(repository: PasscodeRepositoryType) {
        
        self.isTouchIDAllowed = UserDefaults.standard.bool(forKey: "isTouchIDAllowed")
        self.repository = repository
    }
    
    init() {
        
        self.isTouchIDAllowed = UserDefaults.standard.bool(forKey: "isTouchIDAllowed")
        self.repository = UserDefaultsPasscodeRepository()
    }
}
