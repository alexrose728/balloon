//
//  LocationView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//
import SwiftUI

struct LocationView: View {
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        HStack {
            if locationManager.currentLocation != nil {
                locationDetails
            } else {
                loadingIndicator
            }
        }
    }
    
    private var locationDetails: some View {
        VStack(alignment: .leading) {
            Text("Current Location")
            Text("Lat: \(formattedLatitude)")
            Text("Lon: \(formattedLongitude)")
        }
        .font(.caption)
    }
    
    private var loadingIndicator: some View {
        HStack {
            ProgressView()
            Text("Fetching location...")
                .font(.caption)
        }
    }
    
    private var formattedLatitude: String {
        formatCoordinate(locationManager.currentLocation?.latitude)
    }
    
    private var formattedLongitude: String {
        formatCoordinate(locationManager.currentLocation?.longitude)
    }
    
    private func formatCoordinate(_ value: Double?) -> String {
        value?.formatted(.number.precision(.fractionLength(4))) ?? "N/A"
    }
}
