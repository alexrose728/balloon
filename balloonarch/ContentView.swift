//
//  ContentView.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.userSession != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}
