//
//  Error+Extensions.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 04.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation

func perfromThrowing(_ closure: () throws -> Void, onError handle: (Error) -> Void = { print($0.localizedDescription) }) {
    do {
        try closure()
    } catch {
        handle(error)
    }
}
