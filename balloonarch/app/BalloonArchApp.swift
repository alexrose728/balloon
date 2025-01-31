//
//  BalloonArch.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import SwiftUI
import FirebaseCore

@main
struct BalloonRecycleApp: App {
    // MARK: - Properties
    @StateObject var authService = AuthService.shared
    @StateObject var firestoreService = FirestoreService.shared
    
    // MARK: - Initialization
    init() {
        FirebaseApp.configure()
    }
    
    // MARK: - Main View Hierarchy
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.userSession != nil {
                    MainTabView()
                        .transition(.opacity)
                } else {
                    LoginView()
                        .transition(.opacity)
                }
            }
            .environmentObject(authService)
            .environmentObject(firestoreService)
            .onAppear(perform: configureAppearance)
        }
    }
    
    // MARK: - UI Configuration
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .systemPurple
    }
}

// MARK: - Root Tab View
struct MainTabView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            SellView()
                .tabItem {
                    Label("Sell", systemImage: "plus.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.purple)
        .onAppear {
            authService.verifySession()
        }
    }
}
