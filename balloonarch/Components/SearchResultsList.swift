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

struct SearchResultsList: View {
    let arches: [BalloonArch]
    @State private var selectedArch: BalloonArch?
    
    var body: some View {
        List(arches) { arch in
            ArchCardView(arch: arch)
                .onTapGesture {
                    selectedArch = arch
                }
        }
//        .sheet(item: $selectedArch) { arch in
//            ArchDetailView(arch: arch)
//        }
    }
}

struct ArchCardView: View {
    let arch: BalloonArch
    @EnvironmentObject var locationManager: LocationManager
    
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

// MARK: - Subcomponents
struct WrapBadgeView: View {
    let items: [String]
    
    var body: some View {
        HStack {
            ForEach(items, id: \.self) { color in
                Text(color)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
    }
}

struct AvailabilityIndicator: View {
    let availableUntil: Date
    
    var status: (text: String, color: Color) {
        let daysRemaining = Calendar.current.dateComponents([.day], from: Date(), to: availableUntil).day ?? 0
        
        switch daysRemaining {
        case ...0: return ("Expired", .red)
        case 1...3: return ("Last Days", .orange)
        default: return ("Available", .green)
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(status.color)
                .frame(width: 8, height: 8)
            Text(status.text)
        }
    }
}

// MARK: - Preview
struct SearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        let locationManager = LocationManager()
        locationManager.currentLocation = CLLocationCoordinate2D(
            latitude: 37.7749,
            longitude: -122.4194
        )
        
        return SearchResultsList(arches: [
            BalloonArch(
                id: "1",
                colors: ["red", "blue"],
                location: GeoPoint(latitude: 37.7749, longitude: -122.4194),
                price: 49.99,
                quantity: 2,
                userId: "user123",
                imageUrls: ["https://example.com/arch.jpg"],
                createdAt: Date(),
                availableUntil: Date().addingTimeInterval(86400 * 5)
            )
        ])
        .environmentObject(locationManager)
    }
}
