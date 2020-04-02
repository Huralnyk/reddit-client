//
//  RedditEntryTableViewCell.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit
import Combine

private let imageCache = NSCache<NSURL, UIImage>()

class RedditEntryTableViewCell: UITableViewCell, Reusable, NibLoadable {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var thumbnailView: UIImageView?
    @IBOutlet private weak var commentsCounterLabel: UILabel?
    @IBOutlet private weak var footnoteLabel: UILabel?
    
    private var imageDownload: AnyCancellable?

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownload?.cancel()
    }
    
    // MARK: - Input
    
    func render(_ viewModel: RedditEntryViewModel) {
        titleLabel?.text = viewModel.title
        commentsCounterLabel?.text = viewModel.comments
        footnoteLabel?.text = viewModel.footnote
        
        if let cached = imageCache.object(forKey: viewModel.image as NSURL) {
            thumbnailView?.image = cached
        } else {
            imageDownload = URLSession.shared
                .dataTaskPublisher(for: viewModel.image)
                .map(\.data)
                .map(UIImage.init)
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] image in
                    self?.thumbnailView?.image = image
                    self?.thumbnailView?.isHidden = image == nil
                })
        }
    }
}
