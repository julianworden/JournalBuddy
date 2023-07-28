//
//  TestData.swift
//  JournalBuddyUnitTests
//
//  Created by Julian Worden on 7/22/23.
//

@testable import JournalBuddy

enum TestData {
    static let textEntryNoID = TextEntry(id: "", creatorUID: "xjWCRKbeM0P4STJXi2s32CuYurL2", unixDate: 1690082431, text: "Today was a great day.")

    static let textEntryArray = [
        TextEntry(id: "0", creatorUID: "asdf1234", unixDate: 12345678, text: "What a great day!"),
        TextEntry(id: "1", creatorUID: "qwer1234", unixDate: 44562363, text: "What a bad day!"),
        TextEntry(id: "2", creatorUID: "zxcv1234", unixDate: 75684739, text: "What a terrible day!"),
        TextEntry(id: "3", creatorUID: "hjkl1234", unixDate: 10389475, text: "What an amazing day!"),
        TextEntry(id: "4", creatorUID: "uiop1234", unixDate: 30927456, text: "What a fantastic day!")
    ]
}
