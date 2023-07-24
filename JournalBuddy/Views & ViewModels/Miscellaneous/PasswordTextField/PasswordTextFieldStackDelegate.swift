//
//  PasswordTextFieldStackDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/24/23.
//

protocol PasswordTextFieldStackDelegate: AnyObject {
    func passwordTextFieldWasEdited(textFieldText: String)
}
