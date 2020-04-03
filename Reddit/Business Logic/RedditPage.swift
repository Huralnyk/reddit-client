//
//  RedditPage.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

struct RedditPage {
    let children: [RedditEntry]
}

extension RedditPage: Decodable {
    enum WrapperCodingKeys: String, CodingKey {
        case data
    }
    
    enum CodingKeys: String, CodingKey {
        case children
    }
    
    init(from decoder: Decoder) throws {
        let wrapperContainer = try decoder.container(keyedBy: WrapperCodingKeys.self)
        let container = try wrapperContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
        self.children = try container.decode([RedditEntry].self, forKey: .children)
    }
}
