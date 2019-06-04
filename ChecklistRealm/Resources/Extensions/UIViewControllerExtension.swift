//
//  UIViewControllerExtension.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 04/06/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
    
    /// Returns the initial view controller on a storyboard
    static func getInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    
}
