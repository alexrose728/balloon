//
//  user.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import FirebaseFirestore         // For GeoPoint
import FirebaseFirestoreSwift    // For @DocumentID

struct AppUser: Codable, Identifiable {
    @DocumentID var id: String?
    let email: String
    var displayName: String?
    var photoURL: String?
    var location: GeoPoint?
    var createdAt: Date?
}

    // Explicit coding keys if needed
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName
        case photoURL
    }
