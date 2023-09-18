//
//  GoalsViewDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 9/18/23.
//

import Foundation

protocol GoalsViewDelegate: AnyObject {
    func goalsViewDidSelect(goalToEdit: Goal)
}
