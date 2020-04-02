//
//  RedditEntryViewModel.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

struct RedditEntryViewModel {
    
    let title: String
    let image: URL
    let comments: String
    let footnote: String
    
    init(entry: RedditEntry) {
        self.title = entry.title
        self.image = entry.thumbnail
        self.comments = Formatters.comments(entry.numberOfComments)
        self.footnote = Formatters.footnote(entry.author, entry.created)
    }
}
