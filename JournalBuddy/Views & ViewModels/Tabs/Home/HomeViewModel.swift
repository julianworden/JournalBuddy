//
//  HomeViewModel.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/9/23.
//

import Foundation

final class HomeViewModel: MainViewModel {
    var error: Error?

    func logOut() {
        do {
            try AuthService.shared.logOut()
        } catch {
            self.error = error
        }
    }
}

