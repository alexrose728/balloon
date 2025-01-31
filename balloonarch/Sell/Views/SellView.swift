//
//  SellView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//
import SwiftUI
import PhotosUI

struct SellView: View {
    @StateObject private var vm = SellViewModel()
    @State private var showImagePicker = false
    
    // MARK: - Main Body
    var body: some View {
        NavigationStack {
            Form {
                colorSection
                priceQuantitySection
                imageSection
                locationSection
                availabilitySection
                submitSection
            }
            .navigationTitle("Sell Your Arch")
            .configureAlerts(viewModel: vm)
//            .sheet(isPresented: $showImagePicker) {
//                ImagePicker(images: $vm.selectedImages)
//            }
        }
    }
    
    // MARK: - Form Sections
    private var colorSection: some View {
        Section("Color Theme") {
            ColorGrid(selectedColors: $vm.colors)
        }
    }
    
    private var priceQuantitySection: some View {
        Section("Pricing Details") {
            HStack {
                priceField
                Divider()
                quantityField
            }
        }
    }
    
    private var imageSection: some View {
        Section("Upload Photos") {
            ImageUploadView(images: $vm.selectedImages, showImagePicker: $showImagePicker)
        }
    }
    
    private var locationSection: some View {
        Section("Location") {
            LocationView(locationManager: vm.locationManager)
        }
    }
    
    private var availabilitySection: some View {
        Section("Availability") {
            DatePicker(
                "Available Until",
                selection: $vm.availableUntil,
                in: vm.availabilityDateRange,
                displayedComponents: .date
            )
        }
    }
    
    private var submitSection: some View {
        Section {
            Button(action: vm.submitListing) {
                submitButtonContent
            }
            .disabled(!vm.isFormValid || vm.isLoading)
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Subcomponents
    private var priceField: some View {
        TextField("Price", text: $vm.price)
            .keyboardType(.decimalPad)
    }
    
    private var quantityField: some View {
        TextField("Quantity", text: $vm.quantity)
            .keyboardType(.numberPad)
    }
    
    private var submitButtonContent: some View {
        Group {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("List Your Arch")
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - View Modifiers
extension View {
    func configureAlerts(viewModel: SellViewModel) -> some View {
        self
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your balloon arch has been listed successfully!")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
    }
}

//// MARK: - Preview
//struct SellView_Previews: PreviewProvider {
//    static var previews: some View {
//        SellView()
//            .environmentObject(LocationManager.shared)
//    }
//}
