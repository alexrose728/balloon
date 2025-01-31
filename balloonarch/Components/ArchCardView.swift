//
//  ArchCardView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/3/25.
//
import SwiftUI
import SDWebImageSwiftUI
import CoreLocation
import FirebaseFirestoreInternal
import MapKit

struct ArchCardView: View {
    let arch: BalloonArch
//    @EnvironmentObject var locationManager: LocationManager
    @StateObject var locationManager = LocationManager()
    
    private var distanceString: String {
        guard let userCoordinate = locationManager.currentLocation else { return "N/A" }
        
        // Convert both locations to CLLocation
        let userLocation = CLLocation(
            latitude: userCoordinate.latitude,
            longitude: userCoordinate.longitude
        )
        let archLocation = CLLocation(
            latitude: arch.location.latitude,
            longitude: arch.location.longitude
        )
        
        let distance = userLocation.distance(from: archLocation) / 1609 // meters to miles
        return String(format: "%.1f mi", distance)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image Section
            if let imageUrlString = arch.imageUrls.first,
               let imageUrl = URL(string: imageUrlString) {
                WebImage(url: imageUrl)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            
            // Details Section
            VStack(alignment: .leading, spacing: 4) {
                // Color Tags
                WrapBadgeView(items: arch.colors.prefix(3).map { $0.capitalized })
                
                // Price and Quantity
                HStack {
                    Text(arch.price.formatted(.currency(code: "USD")))
                        .font(.headline)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("Qty: \(arch.quantity)")
                        .font(.subheadline)
                }
                
                // Distance and Availability
                HStack {
                    Label(distanceString, systemImage: "location")
                    Spacer()
                    AvailabilityIndicator(availableUntil: arch.availableUntil)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
