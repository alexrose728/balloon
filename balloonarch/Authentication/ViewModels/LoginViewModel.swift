//
//  LoginViewModel.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import Foundation
import Combine
import FirebaseAuth

@MainActor
class LoginViewModel: ObservableObject {
//    private let authService = AuthService.shared

    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var showError = false
    
    // MARK: - Dependencies
    private let authService: AuthService
    
    // MARK: - Initialization
    init(authService: AuthService = .shared) {
        self.authService = authService
    }
    
    // MARK: - Authentication Methods
    func login() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.login(withEmail: email, password: password)
        } catch {
            handleAuthError(error)
        }
    }
    
    func createAccount() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.createUser(withEmail: email, password: password)
        } catch {
            handleAuthError(error)
        }
    }
    
    // MARK: - Error Handling
    private func handleAuthError(_ error: Error) {
        let message: String
        
        switch error {
        case let authError as AuthErrorCode where authError.code == .userNotFound:
            message = "Account not found. Please create an account first."
        case let authError as AuthErrorCode where authError.code == .wrongPassword:
            message = "Incorrect password. Please try again."
        case let authError as AuthErrorCode where authError.code == .emailAlreadyInUse:
            message = "This email is already registered. Please log in instead."
        case let authError as AuthErrorCode where authError.code == .weakPassword:
            message = "Password should be at least 6 characters long."
        case let authError as AuthErrorCode where authError.code == .invalidEmail:
            message = "Please enter a valid email address."
        default:
            message = "An unexpected error occurred. Please try again."
        }
        
        errorMessage = message
        showError = true
    }
    
    // MARK: - Validation
    var isValidForm: Bool {
        !email.isEmpty && email.contains("@") && !password.isEmpty && password.count >= 6
    }
}
