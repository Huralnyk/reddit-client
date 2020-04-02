//
//  NetworkService.swift
//  Reddit
//
//  Created by Oleksii Huralnyk on 02.04.2020.
//  Copyright © 2020 Oleksii Huralnyk. All rights reserved.
//

import Foundation
import Combine

protocol NetworkService {
    func get(path: String, parameters: [String: Any], then handler: @escaping (Result<Data, Error>) -> Void)
}

final class NetworkServiceImpl: NetworkService {
    
    private let session: URLSession
    private let baseURL: URL
    private var requests: Set<AnyCancellable> = []
    
    init(baseURL: URL = URL(string: "https://www.reddit.com")!, session: URLSession = .shared) {
        self.session = session
        self.baseURL = baseURL
    }
    
    func get(path: String, parameters: [String: Any], then handler: @escaping (Result<Data, Error>) -> Void) {
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.map { URLQueryItem(name: $0, value: "\($1)")}
        
        session.dataTaskPublisher(for: components?.url ?? url)
            .sink(
                receiveCompletion: { completion in
                    if case let .failure(error) = completion {
                        handler(.failure(error))
                    }
                },
                receiveValue: { data, _ in
                    handler(.success(data))
                }
            ).store(in: &requests)
    }
}
