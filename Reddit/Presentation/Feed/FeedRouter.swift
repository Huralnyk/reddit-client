//
//  FeedRouter.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 03.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import UIKit
import SafariServices

protocol Router {
    associatedtype Route
    func route(to route: Route)
}

final class FeedRouter: Router {
    enum Route {
        case webView(url: URL)
    }
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func route(to route: Route) {
        switch route {
        case .webView(let url):
            let destination = SFSafariViewController(url: url)
            viewController?.present(destination, animated: true)
        }
    }
}
