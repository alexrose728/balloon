//
//  SearchResultsList.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//

import SwiftUI
import SDWebImageSwiftUI
import CoreLocation
import FirebaseFirestoreInternal
import MapKit

struct SearchResultsList: View {
    let arches: [BalloonArch]
    @State private var selectedArch: BalloonArch?
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        List(arches) { arch in
            ArchCardView(arch: arch)
                .environmentObject(locationManager)
                .onTapGesture {
                    selectedArch = arch
                }
        }
        .sheet(item: $selectedArch) { arch in
            ArchDetailView(arch: arch)
        }
    }
}
//
//struct ArchCardView: View {
//    let arch: BalloonArch
//    @EnvironmentObject var locationManager: LocationManager
////    @StateObject var locationManager = LocationManager()
//    
//    private var distanceString: String {
//        guard let userCoordinate = locationManager.currentLocation else { return "N/A" }
//        
//        // Convert both locations to CLLocation
//        let userLocation = CLLocation(
//            latitude: userCoordinate.latitude,
//            longitude: userCoordinate.longitude
//        )
//        let archLocation = CLLocation(
//            latitude: arch.location.latitude,
//            longitude: arch.location.longitude
//        )
//        
//        let distance = userLocation.distance(from: archLocation) / 1609 // meters to miles
//        return String(format: "%.1f mi", distance)
//    }
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            // Image Section
//            if let imageUrlString = arch.imageUrls.first,
//               let imageUrl = URL(string: imageUrlString) {
//                WebImage(url: imageUrl)
//                    .resizable()
//                    .indicator(.activity)
//                    .transition(.fade(duration: 0.5))
//                    .scaledToFill()
//                    .frame(width: 100, height: 100)
//                    .cornerRadius(8)
//                    .clipped()
//            } else {
//                Image(systemName: "photo")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 100, height: 100)
//                    .foregroundColor(.gray)
//            }
//            
//            // Details Section
//            VStack(alignment: .leading, spacing: 4) {
//                // Color Tags
//                WrapBadgeView(items: arch.colors.prefix(3).map { $0.capitalized })
//                
//                // Price and Quantity
//                HStack {
//                    Text(arch.price.formatted(.currency(code: "USD")))
//                        .font(.headline)
//                    
//                    Text("•")
//                        .foregroundColor(.secondary)
//                    
//                    Text("Qty: \(arch.quantity)")
//                        .font(.subheadline)
//                }
//                
//                // Distance and Availability
//                HStack {
//                    Label(distanceString, systemImage: "location")
//                    Spacer()
//                    AvailabilityIndicator(availableUntil: arch.availableUntil)
//                }
//                .font(.caption)
//                .foregroundColor(.secondary)
//            }
//        }
//        .padding(.vertical, 8)
//    }
//}
//
//struct ArchDetailView: View {
//    let arch: BalloonArch
//    @EnvironmentObject var locationManager: LocationManager
//    @State private var region: MKCoordinateRegion
//    @State private var showContactSheet = false
//    
//    init(arch: BalloonArch) {
//        self.arch = arch
//        let center = CLLocationCoordinate2D(
//            latitude: arch.location.latitude,
//            longitude: arch.location.longitude
//        )
//        _region = State(initialValue: MKCoordinateRegion(
//            center: center,
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        ))
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Image Gallery
//                imageGallerySection
//                
//                // Basic Info
//                basicInfoSection
//                
//                // Map Section
//                mapSection
//                
//                // Availability
//                availabilitySection
//                
//                // Contact Button
//                contactButton
//            }
//            .padding()
//        }
//        .navigationTitle("Arch Details")
//        .navigationBarTitleDisplayMode(.inline)
//        .sheet(isPresented: $showContactSheet) {
//            ContactSellerView(arch: arch)
//        }
//    }
//    
//    // MARK: - Subviews
//    
//    private var imageGallerySection: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 10) {
//                ForEach(arch.imageUrls, id: \.self) { urlString in
//                    WebImage(url: URL(string: urlString))
//                        .resizable()
//                        .indicator(.activity)
//                        .transition(.fade(duration: 0.5))
//                        .scaledToFill()
//                        .frame(width: 250, height: 200)
//                        .cornerRadius(12)
//                        .clipped()
//                }
//            }
//        }
//    }
//    
//    private var basicInfoSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack {
//                Text(arch.price.formatted(.currency(code: "USD")))
//                    .font(.title2.bold())
//                
//                Text("• Qty: \(arch.quantity)")
//                    .font(.title3)
//                    .foregroundColor(.secondary)
//            }
//            
//            Text("Colors:")
//                .font(.headline)
//                .padding(.top, 8)
//            
//            WrapBadgeView(items: arch.colors.map { $0.capitalized })
//            
//            HStack {
//                Image(systemName: "location")
//                Text(distanceString)
//                Spacer()
//                AvailabilityIndicator(availableUntil: arch.availableUntil)
//            }
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//            .padding(.top, 8)
//        }
//    }
//    
//    private var mapSection: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Location")
//                .font(.headline)
//            
//            Map(coordinateRegion: $region, annotationItems: [arch]) { arch in
//                MapMarker(
//                    coordinate: CLLocationCoordinate2D(
//                        latitude: arch.location.latitude,
//                        longitude: arch.location.longitude
//                    ),
//                    tint: .blue
//                )
//            }
//            .frame(height: 200)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color(.systemGray4), lineWidth: 1)
//            )
//        }
//    }
//    
//    private var availabilitySection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Availability")
//                .font(.headline)
//            
//            HStack {
//                Image(systemName: "clock")
//                Text("Available until:")
//                Spacer()
//                Text(arch.availableUntil.formatted(date: .abbreviated, time: .omitted))
//            }
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//        }
//    }
//    
//    private var contactButton: some View {
//        Button {
//            showContactSheet = true
//        } label: {
//            Text("Contact Seller")
//                .font(.headline)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(12)
//        }
//    }
//    
//    // MARK: - Helper Properties
//    
//    private var distanceString: String {
//        guard let userCoordinate = locationManager.currentLocation else { return "N/A" }
//        
//        let userLocation = CLLocation(
//            latitude: userCoordinate.latitude,
//            longitude: userCoordinate.longitude
//        )
//        let archLocation = CLLocation(
//            latitude: arch.location.latitude,
//            longitude: arch.location.longitude
//        )
//        
//        let distance = userLocation.distance(from: archLocation) / 1609
//        return String(format: "%.1f miles away", distance)
//    }
//}
//
//struct ContactSellerView: View {
//    let arch: BalloonArch
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section {
//                    Text("Contact information for \(arch.userId)")
//                    // Add actual contact form fields here
//                }
//            }
//            .navigationTitle("Contact Seller")
//            .navigationBarTitleDisplayMode(.inline)
//        }
//    }
//}
//// MARK: - Subcomponents
//struct WrapBadgeView: View {
//    let items: [String]
//    
//    var body: some View {
//        HStack {
//            ForEach(items, id: \.self) { color in
//                Text(color)
//                    .font(.caption)
//                    .padding(.horizontal, 8)
//                    .padding(.vertical, 4)
//                    .background(Color(.systemGray5))
//                    .cornerRadius(8)
//            }
//        }
//    }
//}
//
//struct AvailabilityIndicator: View {
//    let availableUntil: Date
//    
//    var status: (text: String, color: Color) {
//        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: availableUntil).day ?? 0
//        
//        switch daysRemaining {
//        case ...0: return ("Expired", .red)
//        case 1...3: return ("Last Days", .orange)
//        default: return ("Available", .green)
//        }
//    }
//    
//    var body: some View {
//        HStack {
//            Circle()
//                .fill(status.color)
//                .frame(width: 8, height: 8)
//            Text(status.text)
//        }
//    }
//}

// MARK: - Preview
//struct SearchResultsList_Previews: PreviewProvider {
//    static var previews: some View {
//        let locationManager = LocationManager()
//        locationManager.currentLocation = CLLocationCoordinate2D(
//            latitude: 37.7749,
//            longitude: -122.4194
//        )
//        
//        return SearchResultsList(arches: [
//            BalloonArch(
//                id: "1",
//                colors: ["red", "blue"],
//                location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
//                price: 49.99,
//                quantity: 2,
//                userId: "user123",
//                imageUrls: ["https://example.com/arch.jpg"],
//                createdAt: Date(),
//                availableUntil: Date().addingTimeInterval(86400 * 5)
//            )
//        ])
//        .environmentObject(locationManager)
//    }
//}
