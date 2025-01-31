//
//  BalloonArch.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import Firebase

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var displayName: String?
    var location: GeoPoint?
}

struct BalloonArch: Codable, Identifiable {
    @DocumentID var id: String?
    let colors: [String]
    let location: GeoPoint
    let price: Double
    let quantity: Int
    let userId: String
    let imageUrls: [String]
    let createdAt: Date
    let availableUntil: Date
}

