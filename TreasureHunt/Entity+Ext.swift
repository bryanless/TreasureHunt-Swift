//
//  Entity+Ext.swift
//  TreasureHunt
//
//  Created by Bryan on 15/08/23.
//

import Combine
import Foundation
import RealityKit

extension Entity {
    func loadEntityAsync (
        fileName: String,
        fileExtension: String,
        completion: @escaping (Result<Entity, Error>) -> Void
    ) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: fileExtension) else { return }

        // Add URL Path from Bundle
        let url = URL(filePath: path)

        let loadRequest = Entity.loadAsync(contentsOf: url)

        var cancellable: AnyCancellable?
        cancellable = loadRequest
            .sink(receiveCompletion: { loadCompletion in
                if case let .failure(error) = loadCompletion {
                    completion(.failure(error))
                }
                cancellable?.cancel()
            }, receiveValue: { entity in
                completion(.success(entity))
                cancellable?.cancel()
            })
    }
}
