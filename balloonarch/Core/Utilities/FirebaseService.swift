//
//  FirebaseService.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//

import Firebase

class FirebaseService {
    static let shared = FirebaseService()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    
    private init() {
        FirebaseApp.configure()
    }
}

