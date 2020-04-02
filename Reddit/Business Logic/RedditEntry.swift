//
//  RedditEntry.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

struct RedditEntry {
    let title: String
    let author: String
    let numberOfComments: Int
    let thumbnail: URL
    let previewImage: URL?
    let created: Date
}

// MARK: - Mapping

extension RedditEntry: Decodable {
    
    private struct Preview: Decodable {
        let images: [Image]
    }
    
    private struct Image: Decodable {
        enum WrapperCodingKeys: String, CodingKey {
            case source
        }
        
        enum CodingKeys: String, CodingKey {
            case url
        }
        
        let url: URL
        
        init(from decoder: Decoder) throws {
            let wrapperContainer = try decoder.container(keyedBy: WrapperCodingKeys.self)
            let container = try wrapperContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .source)
            self.url = try container.decode(URL.self, forKey: .url)
        }
    }
    
    enum WrapperCodingKeys: String, CodingKey {
        case data
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case author = "author_fullname"
        case created
        case thumbnail
        case preview
        case numberOfComments = "num_comments"
    }
    
    init(from decoder: Decoder) throws {
        let wrapperContainer = try decoder.container(keyedBy: WrapperCodingKeys.self)
        let container = try wrapperContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.title = try container.decode(String.self, forKey: .title)
        self.author = try container.decode(String.self, forKey: .author)
        self.thumbnail = try container.decode(URL.self, forKey: .thumbnail)
        self.numberOfComments = try container.decode(Int.self, forKey: .numberOfComments)
        
        let timestamp = try container.decode(TimeInterval.self, forKey: .created)
        self.created = Date(timeIntervalSince1970: timestamp)
        
        let preview = try container.decodeIfPresent(Preview.self, forKey: .preview)
        self.previewImage = preview?.images.first?.url
    }
}
