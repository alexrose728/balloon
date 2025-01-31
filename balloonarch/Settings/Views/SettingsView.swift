//
//  SettingsView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var vm = SettingsViewModel()
    @EnvironmentObject var authService: AuthService
    @AppStorage("appTheme") private var appTheme: String = "system"
    @AppStorage("notificationsEnabled") var notificationsEnabled = true
    @AppStorage("darkModeEnabled") var darkModeEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                
                Section("Profile Information") {
                    if let user = vm.user {
                        UserProfileSection(user: user)
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .task {
                                await vm.loadUserData()
                            }
                    }
                }
                
                Section("Account Settings") {
                    NavigationLink("Edit Profile") {
                        EditProfileView()
                    }
                    
                    NavigationLink("Change Password") {
                        ChangePasswordView()
                    }
                }
                
                Section("Preferences") {
                    Toggle("Enable Notifications", isOn: $vm.notificationsEnabled)
                    Picker("Theme", selection: $appTheme) {
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("System").tag("system")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(role: .destructive) {
                        vm.showLogoutConfirmation = true
                    } label: {
                        Text("Log Out")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Log Out", isPresented: $vm.showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button(role: .destructive) {
                    Task {
                        await vm.logout()
                    }
                } label: {
                    Text("Are you sure you want to log out?")
                }
                .alert("Error", isPresented: $vm.showError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(vm.errorMessage)
                }
                
                            .alert("Error", isPresented: $vm.showError) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text(vm.errorMessage)
                            }
            }
        }
    }
    
    // MARK: - Subviews
    private struct UserProfileSection: View {
        let user: AppUser  // Now properly recognized
        
        var body: some View {
            HStack {
                if let photoURLString = user.photoURL,
                   let photoURL = URL(string: photoURLString) {
                    AsyncImage(url: photoURL) { phase in
                        if let image = phase.image {
                            image.resizable()
                        } else if phase.error != nil {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading) {
                    Text(user.displayName ?? "User")
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    struct EditProfileView: View {
        @StateObject private var vm = EditProfileViewModel()
        
        var body: some View {
            Form {
                Section("Profile Picture") {
                    ProfilePictureEditor(image: $vm.profileImage)
                }
                
                Section("Personal Information") {
                    TextField("Display Name", text: $vm.displayName)
                }
                
                Section {
                    Button("Save Changes") {
                        Task { await vm.saveChanges() }
                    }
                    .disabled(!vm.hasChanges)
                }
            }
            .navigationTitle("Edit Profile")
            .alert("Success", isPresented: $vm.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Profile updated successfully!")
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
            .task {
                await vm.loadUserData()
            }
        }
    }
    
    struct ChangePasswordView: View {
        @StateObject private var vm = ChangePasswordViewModel()
        
        var body: some View {
            Form {
                Section("Current Password") {
                    SecureField("Enter current password", text: $vm.currentPassword)
                }
                
                Section("New Password") {
                    SecureField("Enter new password", text: $vm.newPassword)
                    SecureField("Confirm new password", text: $vm.confirmPassword)
                }
                
                Section {
                    Button("Change Password") {
                        Task { await vm.changePassword() }
                    }
                    .disabled(!vm.isFormValid)
                }
            }
            .navigationTitle("Change Password")
            .alert("Success", isPresented: $vm.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Password changed successfully!")
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
        }
    }
}
