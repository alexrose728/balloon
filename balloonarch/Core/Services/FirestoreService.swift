//
//  FirestoreService.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    
    let db: Firestore
    
    private init() {
        self.db = Firestore.firestore()
        configureFirestore()
    }
    
    private func configureFirestore() {
        let settings = db.settings
        settings.isPersistenceEnabled = true
        settings.cacheSizeBytes = FirestoreCacheSizeUnlimited
        db.settings = settings
    }
}

// MARK: - Balloon Arch Operations
extension FirestoreService {
    func fetchArches(colors: [String], location: GeoPoint) async throws -> [BalloonArch] {
        let collection = db.collection("balloonArches")
            .whereField("availableUntil", isGreaterThan: Date())
        
        let query = colors.isEmpty ? collection : collection
            .whereField("colors", arrayContainsAny: colors)
        
        let snapshot = try await query.getDocuments()
        return try snapshot.documents.compactMap { try $0.data(as: BalloonArch.self) }
    }
    
    func saveArch(_ arch: BalloonArch) async throws {
        try db.collection("balloonArches")
            .document(arch.id ?? UUID().uuidString)
            .setData(from: arch, merge: true)
    }
}

// MARK: - User Operations
extension FirestoreService {
    func saveUser(_ user: AppUser) async throws {
        guard let userId = user.id else {
            throw NSError(domain: "FirestoreError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID"])
        }
        
        try db.collection("users")
            .document(userId)
            .setData(from: user, merge: true)
    }
    
    func fetchUser(uid: String) async throws -> AppUser? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try document.data(as: AppUser.self)
    }
}

