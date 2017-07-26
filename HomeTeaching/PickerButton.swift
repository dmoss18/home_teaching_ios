//
//  PickerButton.swift
//  HomeTeaching
//
//  Created by Devin Moss on 7/26/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit

class PickerButton : UIButton {
    override open var canBecomeFirstResponder : Bool {
        return true
    }
    
    open var customInputView: UIView?
    open var customInputAccessoryView: UIView?
    
    override open var inputView: UIView {
        get {
            if customInputView != nil {
                return customInputView!
            } else {
                return super.inputView!
            }
        }
    }
    
    override open var inputAccessoryView: UIView {
        get {
            if customInputAccessoryView != nil {
                return customInputAccessoryView!
            } else {
                return super.inputAccessoryView!
            }
        }
    }
}
