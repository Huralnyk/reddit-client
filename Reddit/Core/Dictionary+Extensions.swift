//
//  Dictionary+Extensions.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 04.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

extension Dictionary {
    func adding(value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var copy = self
        copy[key] = value
        return copy
    }
}
