//
//  UITableView+Extensions.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var nibName: String { get }
}

extension NibLoadable where Self: UITableViewCell {
    static var nibName: String {
        return String(describing: self)
    }
}

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable where Self: UITableViewCell {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellType: T.Type) where T: NibLoadable, T: Reusable {
        register(UINib(nibName: T.nibName, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeue<T: UITableViewCell>(_ cellType: T.Type, for indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("\(T.reuseIdentifier) is not registered as reusable cell")
        }
        return cell
    }
}
