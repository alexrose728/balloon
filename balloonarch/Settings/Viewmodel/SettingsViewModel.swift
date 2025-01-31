//
//  SettingsViewModel.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import SwiftUI
import Firebase

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var user: AppUser?
    @Published var notificationsEnabled = true
    @Published var darkModeEnabled = false
    @Published var showLogoutConfirmation = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthService.shared
    private let firestoreService = FirestoreService.shared
    let locationManager = LocationManager.shared
    
    func loadUserData() async {
            guard let userId = authService.currentUser?.id else {
                errorMessage = "User not authenticated"
                showError = true
                return
            }
            
            do {
                user = try await firestoreService.fetchUser(uid: userId)
            } catch {
                errorMessage = error.localizedDescription
                showError = true
                print("Error loading user data: \(error)")
            }
        }
    
    func logout() async {
        do {
            try await authService.signOut()
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var profileImage: UIImage?
    @Published var displayName = ""
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let authService = AuthService.shared
    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    
    var hasChanges: Bool {
        !displayName.isEmpty
    }
    
    func loadUserData() async {
        guard let user = authService.currentUser else { return }
        displayName = user.displayName ?? "Name"
    }
    
    func saveChanges() async {
        do {
            // Update profile picture if changed
            if let image = profileImage {
                let url = try await uploadProfileImage(image)
                try await authService.updateProfilePhoto(url: url)
            }
            
            // Update display name
            if !displayName.isEmpty {
                try await authService.updateDisplayName(displayName)
            }
            
            showSuccess = true
        } catch {
            handleError(error)
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) async throws -> URL {
        guard let data = image.jpegData(compressionQuality: 0.1) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }
        let urlString = try await storageService.uploadImage(
            data: data,
            userId: authService.currentUser?.id ?? "unknown",
            path: "profile_pictures"
        )
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        return url
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

@MainActor
class ChangePasswordViewModel: ObservableObject {
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    @Published var showSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    var isFormValid: Bool {
        !currentPassword.isEmpty &&
        !newPassword.isEmpty &&
        newPassword == confirmPassword &&
        newPassword.count >= 6 &&
        isNewPasswordValid
    }
    
    var isNewPasswordValid: Bool {
        newPassword != currentPassword
    }
    func changePassword() async {
        do {
            guard let email = Auth.auth().currentUser?.email else {
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }
            
            // Reauthenticate user
            let credential = EmailAuthProvider.credential(
                withEmail: email,
                password: currentPassword
            )
            try await Auth.auth().currentUser?.reauthenticate(with: credential)
            
            // Update password
            try await Auth.auth().currentUser?.updatePassword(to: newPassword)
            
            showSuccess = true
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
//    func startLocationTracking() {
//        switch locationManager.authorizationStatus {
//        case .notDetermined:
//            locationManager.requestAlwaysAuthorization()
//        case .authorizedWhenInUse:
//            // Show alert to upgrade to always access
//            showLocationUpgradeAlert = true
//        case .authorizedAlways:
//            locationManager.startUpdatingLocation()
//        default: break
//        }
//    }
}
