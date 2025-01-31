//
//  AuthService.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//


import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: AppUser?
    
    private init() {
        userSession = Auth.auth().currentUser
        Task {
            try? await loadUserData()
        }
    }
    enum AuthError: Error {
        case noUserSession
        case noUserID
        case documentNotFound
    }
    // MARK: - Authentication Methods
    func login(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        await MainActor.run {
            userSession = result.user
        }
        try await loadUserData()
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        await MainActor.run {
            userSession = result.user
        }
        try await createUserDocument()
    }
    
    func signOut() async throws {
            try Auth.auth().signOut()
            await MainActor.run {
                userSession = nil
                currentUser = nil
            }
        }
    
    // MARK: - Session Management
    func verifySession() {
        let currentAuthUser = Auth.auth().currentUser
        if currentAuthUser == nil {
            Task {
                await MainActor.run {
                    userSession = nil
                    currentUser = nil
                }
            }
        }
    }
    
    // MARK: - User Management
    private func createUserDocument() async throws {
        guard let user = userSession else { throw AuthError.noUserSession }
        
        let appUser = AppUser(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName,
            photoURL: user.photoURL?.absoluteString
        )
        
        try await FirestoreService.shared.saveUser(appUser)
        await MainActor.run {
            currentUser = appUser
        }
    }
    
    private func loadUserData() async throws {
        guard let uid = userSession?.uid else { throw AuthError.noUserID }
        let user = try await FirestoreService.shared.fetchUser(uid: uid)
        await MainActor.run {
            currentUser = user
        }
    }
}

// MARK: - Profile Updates
extension AuthService {
    func updateDisplayName(_ name: String) async throws {
        guard let user = userSession else { throw AuthError.noUserSession }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        try await changeRequest.commitChanges()
        
        var updatedUser = currentUser ?? AppUser(id: user.uid, email: user.email ?? "")
        updatedUser.displayName = name
        try await FirestoreService.shared.saveUser(updatedUser)
        
        await MainActor.run {
            currentUser = updatedUser
        }
    }
    
    func updateProfilePhoto(url: URL) async throws {
        guard let user = userSession else { throw AuthError.noUserSession }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.photoURL = url
        try await changeRequest.commitChanges()
        
        var updatedUser = currentUser ?? AppUser(id: user.uid, email: user.email ?? "")
        updatedUser.photoURL = url.absoluteString
        try await FirestoreService.shared.saveUser(updatedUser)
        
        await MainActor.run {
            currentUser = updatedUser
        }
    }
}
