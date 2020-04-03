//
//  RedditEntryViewModel.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit
import Combine

final class RedditEntryViewModel {
    
    var title: String { entry.title }
    lazy var comments: String = Formatters.comments(entry.numberOfComments)
    lazy var footnote: String = Formatters.footnote(entry.author, entry.created)
    lazy var image = self.makeFutureImage()
    var fullImageURL: URL? { entry.previewImage }
    
    private var imageDownload: AnyCancellable?
    private let entry: RedditEntry
    
    deinit {
        imageDownload?.cancel()
    }
    
    init(entry: RedditEntry) {
        self.entry = entry
    }
    
    private func makeFutureImage() -> Future<UIImage?, Never> {
        let url = entry.thumbnail
        if let cached = Dependencies.imageCache.object(forKey: url as NSURL) {
            return Future { $0(.success(cached)) }
        } else {
            return Future { [weak self] promise in
                self?.imageDownload = URLSession.shared
                    .dataTaskPublisher(for: url)
                    .map(\.data)
                    .map(UIImage.init)
                    .replaceError(with: nil)
                    .handleEvents(receiveOutput: { image in
                        image.map { Dependencies.imageCache.setObject($0, forKey: url as NSURL) }
                    })
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { image in
                        promise(.success(image))
                    })
            }
        }
    }
}
