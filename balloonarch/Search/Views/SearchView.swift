//
//  SearchView.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//

import SwiftUI

struct SearchView: View {
    @StateObject var vm = SearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                SearchFilterControls(vm: vm)
                
                if vm.isLoading {
                    ProgressView()
                } else if vm.filteredArches.isEmpty {
                    // Fixed ContentUnavailableView implementation
                    ContentUnavailableView(
                        "No Results Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search filters")
                    )
                } else {
                    SearchResultsList(arches: vm.filteredArches)
                }
            }
            .navigationTitle("Find Arches")
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
            .alert("Location Error", isPresented: .constant(vm.locationManager.lastError != nil)) {
                Button("OK") { vm.locationManager.lastError = nil }
            } message: {
                Text(vm.locationManager.lastError?.localizedDescription ?? "Unknown location error")
            }
        }
    }
}

