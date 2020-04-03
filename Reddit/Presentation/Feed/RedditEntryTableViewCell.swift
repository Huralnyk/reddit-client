//
//  RedditEntryTableViewCell.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit
import Combine

class RedditEntryTableViewCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var thumbnailView: UIImageView!
    @IBOutlet private weak var commentsCounterLabel: UILabel?
    @IBOutlet private weak var footnoteLabel: UILabel?
    
    private var imageDownload: AnyCancellable?

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel?.text = nil
        thumbnailView?.image = nil
        commentsCounterLabel?.text = nil
        footnoteLabel?.text = nil
        imageDownload?.cancel()
    }
    
    // MARK: - Input
    
    func render(_ viewModel: RedditEntryViewModel) {
        titleLabel?.text = viewModel.title
        commentsCounterLabel?.text = viewModel.comments
        footnoteLabel?.text = viewModel.footnote
        imageDownload = viewModel.image
            .handleEvents(receiveOutput: { [weak self] image in
                self?.thumbnailView.isHidden = image == nil
            })
            .assign(to: \.image, on: thumbnailView)
    }
}
