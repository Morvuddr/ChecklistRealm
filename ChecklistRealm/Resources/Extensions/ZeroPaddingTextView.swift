//
//  ZeroPaddingTextView.swift
//  ChecklistRealm
//
//  Created by Игорь Бопп on 04/06/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

@IBDesignable class ZeroPaddingTextView: UITextView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
    
}
