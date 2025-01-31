//
//  SellView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//
import SwiftUI
import PhotosUI

struct SellView: View {
    @StateObject var vm = SellViewModel()
    @State private var showImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Image Upload Section
                Section("Upload Photos") {
                    ImageUploadView(images: $vm.selectedImages)
                        .frame(height: 150)
                }
                
                // Color Selection
                Section("Select Colors") {
                    ColorGrid(selectedColors: $vm.colors)
                }
                
                // Price & Quantity
                Section("Pricing & Quantity") {
                    TextField("Price", text: $vm.price)
                        .keyboardType(.decimalPad)
                    TextField("Quantity", text: $vm.quantity)
                        .keyboardType(.numberPad)
                }
                
                // Availability Date
                Section("Available Until") {
                    DatePicker(
                        "Select Date",
                        selection: $vm.availableUntil,
                        in: Date()...Date().addingTimeInterval(60*60*24*365), // 1 year range
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }
                
                // Location Section
                Section("Location") {
                    if vm.locationManager.authorizationStatus == .authorizedWhenInUse {
                        LocationView(locationManager: vm.locationManager)
                    } else {
                        Button("Enable Location Access") {
                            vm.locationManager.requestAuthorization()
                        }
                    }
                }
                
                // Submit Button
                Section {
                    Button("List Arch") {
                        vm.submitListing()
                    }
                    .disabled(!vm.isFormValid)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Sell Your Balloons")
            .alert("Success", isPresented: $vm.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your balloons have been listed successfully!")
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
//            scrollDismissesKeyboard(ScrollDismissesKeyboardMode.automatic)
        }
    }
}

// MARK: - Image Upload Component
struct ImageUploadView: View {
    @Binding var images: [UIImage]
    @State private var showImagePicker = false
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(images, id: \.self) { image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .cornerRadius(8)
                }
                
                Button {
                    showImagePicker = true
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 100, height: 100)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(images: $images)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 5
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.images.append(image)
                        }
                    }
                }
            }
        }
    }
}

//// MARK: - Preview
//struct SellView_Previews: PreviewProvider {
//    static var previews: some View {
//        SellView()
//            .environmentObject(AuthService.shared)
//    }
//}
