//
//  SearchViewModel.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import SwiftUI
import Combine
import FirebaseFirestore
import CoreLocation

@MainActor
class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var selectedColors: Set<String> = []
    @Published var searchRadius: Double = 10 // Default 10 miles
    @Published var filteredArches: [BalloonArch] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var currentLocation: CLLocationCoordinate2D?
    
    // MARK: - Services
    private let firestoreService = FirestoreService.shared
    let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupLocationManager()
        setupSearchBindings()
    }
    
    // MARK: - Setup
    private func setupLocationManager() {
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                self?.currentLocation = location
            }
            .store(in: &cancellables)
        
        locationManager.requestAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupSearchBindings() {
        Publishers.CombineLatest3(
            $searchText.debounce(for: .seconds(0.5), scheduler: RunLoop.main),
            $selectedColors,
            $currentLocation
//                .removeDuplicates() // No more error!
        )
        .sink { [weak self] _ in
            self?.performSearch()
        }
        .store(in: &cancellables)
    }
    
    private func setupLocation() {
            locationManager.$authorizationStatus
                .receive(on: RunLoop.main)
                .sink { status in
                    if status == .authorizedWhenInUse {
                        self.locationManager.startUpdatingLocation()
                    }
                }
                .store(in: &cancellables)
        }
    // MARK: - Search Operations
    func performSearch() {
        guard let currentLocation = currentLocation else {
            errorMessage = "Location services are required to search nearby arches"
            showError = true
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                // Convert CLLocation to Firestore GeoPoint
                let geoPoint = currentLocation.geoPoint
                
                // Fetch arches matching color criteria
                var arches = try await firestoreService.fetchArches(
                    colors: Array(selectedColors),
                    location: geoPoint
                )
                
                // Filter by distance
                arches = arches.filter { arch in
                            let distance = currentLocation.distance(from: arch.location.coordinate)
                            return distance <= searchRadius
                        }
                
                filteredArches = arches.sorted {
                            currentLocation.distance(from: $0.location.coordinate) <
                            currentLocation.distance(from: $1.location.coordinate)
                        }
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - Helper Methods
    func toggleColorSelection(_ color: String) {
        if selectedColors.contains(color) {
            selectedColors.remove(color)
        } else {
            selectedColors.insert(color)
        }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

// MARK: - Extensions
extension CLLocationCoordinate2D {
    var geoPoint: GeoPoint {
        GeoPoint(latitude: self.latitude, longitude: self.longitude)
    }
}
    
//    func distance(from coordinate: CLLocationCoordinate2D) -> Double {
//        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
//        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        return from.distance(from: to) / 1609 // Convert meters to miles
//    }
//}

extension GeoPoint {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var clLocation: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLLocationCoordinate2D {
    func distance(from coordinate: CLLocationCoordinate2D) -> Double {
        let from = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to) / 1609 // meters to miles
    }
}

// MARK: - Mock for Previews
extension SearchViewModel {
    static func mock() -> SearchViewModel {
        let vm = SearchViewModel()
        vm.filteredArches = [
            BalloonArch(
                id: "1",
                colors: ["red", "blue"],
                location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
                price: 49.99,
                quantity: 1,
                userId: "user1",
                imageUrls: [],
                createdAt: Date(),
                availableUntil: Date().addingTimeInterval(86400 * 14)
            )
        ]
        return vm
    }
}
