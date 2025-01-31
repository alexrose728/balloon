//
//  SellViewModel.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//
import SwiftUI
import Firebase
import CoreLocation
import Combine

@MainActor
class SellViewModel: ObservableObject {
    @Published var colors: [String] = []
    @Published var price = ""
    @Published var quantity = ""
    @Published var selectedImages: [UIImage] = []
    @Published var availableUntil = Date().addingTimeInterval(60*60*24*14)
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var showSuccess = false
    
    private let firestoreService = FirestoreService.shared
    private let storageService = StorageService.shared
    private let locationManager = LocationManager.shared
    private var cancellables = Set<AnyCancellable>()

    var isFormValid: Bool {
        let hasColors = !colors.isEmpty
        let validPrice = Double(price) != nil
        let validQuantity = Int(quantity) != nil
        let hasImages = !selectedImages.isEmpty
        let hasLocation = locationManager.currentLocation != nil
        
        return hasColors && validPrice && validQuantity && hasImages && hasLocation
    }

    init() {
        locationManager.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        locationManager.requestAuthorization()
        locationManager.startUpdatingLocation()
    }

    func submitListing() {
        guard let userId = Auth.auth().currentUser?.uid,
              let price = Double(price),
              let quantity = Int(quantity),
              let location = locationManager.currentLocation else {
            showError(message: "Please fill all required fields correctly")
            return
        }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let imageUrls = try await uploadImages(userId: userId)
                let arch = BalloonArch(
                    id: UUID().uuidString,
                    colors: colors,
                    location: GeoPoint(latitude: location.latitude, longitude: location.longitude),
                    price: price,
                    quantity: quantity,
                    userId: userId,
                    imageUrls: imageUrls,
                    createdAt: Date(),
                    availableUntil: availableUntil
                )
                
                try await firestoreService.saveArch(arch)
                showSuccess = true
                resetForm()
            } catch {
                showError(message: error.localizedDescription)
            }
        }
    }
    
    private func uploadImages(userId: String) async throws -> [String] {
        try await withThrowingTaskGroup(of: String.self) { group in
            for image in selectedImages {
                guard let data = image.jpegData(compressionQuality: 0.8) else {
                    throw ImageError.invalidImageData
                }
                
                group.addTask {
                    try await self.storageService.uploadImage(
                        data: data,
                        userId: userId,
                        path: "arch_images"
                    )
                }
            }
            
            return try await group.reduce(into: []) { $0.append($1) }
        }
    }
    
    private func resetForm() {
        colors = []
        price = ""
        quantity = ""
        selectedImages = []
    }
    enum ImageError: LocalizedError {
        case invalidImageData
        case uploadFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidImageData:
                return "Could not process image data"
            case .uploadFailed:
                return "Failed to upload image to storage"
            }
        }
    }
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
