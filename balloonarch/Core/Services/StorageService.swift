//
//  StorageService.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import FirebaseStorage

class StorageService {
    static let shared = StorageService()
    private let storage = Storage.storage()
    
    func uploadImage(data: Data, userId: String) async throws -> String {
        let ref = storage.reference().child("arch_images/\(userId)/\(UUID().uuidString).jpg")
        let _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL().absoluteString
    }
}

extension StorageService {
    func uploadImage(data: Data, userId: String, path: String) async throws -> String {
        let ref = storage.reference().child("\(path)/\(userId)/\(UUID().uuidString).jpg")
        let _ = try await ref.putDataAsync(data)
        return try await ref.downloadURL().absoluteString
    }
}
