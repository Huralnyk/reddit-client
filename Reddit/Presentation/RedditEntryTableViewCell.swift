//
//  RedditEntryTableViewCell.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit

extension Date {
    static var now: Date {
        return Date()
    }
}

class RedditEntryTableViewCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var thumbnailView: UIImageView?
    @IBOutlet private weak var commentsCounterLabel: UILabel?
    @IBOutlet private weak var footnoteLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Input
    
    func render(_ viewModel: RedditEntryViewModel) {
        titleLabel?.text = viewModel.title
        commentsCounterLabel?.text = viewModel.comments
        footnoteLabel?.text = viewModel.footnote
    }
    
}
