//
//  File.swift
//  
//
//  Created by Jan Cislinsky (admin) on 04. 04. 2020.
//

import Foundation

struct PersistentStore {
    var model: PersistentModel

    init?() {
        do {
            model = try PersistentStore.readFromFile()
        } catch {
            print("PersistentStore: Failed to init. \(error)")
            return nil
        }
    }

    func save() {
        do {
            try saveToFile()
        } catch {
            print("PersistentStore: Failed to save. \(error)")
        }
    }

    // MARK: -

    private static let modelUrl = URL(fileURLWithPath: Bundle.main.bundlePath + "/../../../PersistentStore/model.json")

    private static func readFromFile() throws -> PersistentModel {
        guard FileManager.default.fileExists(atPath: modelUrl.path) else {
            return PersistentModel(estates: [])
        }
        let modelData = try Data(contentsOf: modelUrl)
        let model = try JSONDecoder().decode(PersistentModel.self, from: modelData)
        return model
    }

    private func saveToFile() throws {
        let modelData = try JSONEncoder().encode(model)
        try modelData.write(to: PersistentStore.modelUrl, options: .atomic)
    }
}
