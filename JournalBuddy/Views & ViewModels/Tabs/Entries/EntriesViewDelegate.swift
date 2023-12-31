//
//  EntriesViewDelegate.swift
//  JournalBuddy
//
//  Created by Julian Worden on 7/30/23.
//

protocol EntriesViewDelegate: AnyObject {
    func entriesViewDidSelectTextEntry(_ entry: TextEntry)
    func entriesViewDidSelectVideoEntry(_ entry: VideoEntry)
    func entriesViewDidSelectVoiceEntry(_ entry: VoiceEntry)
}
