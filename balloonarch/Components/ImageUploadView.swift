//
//  ImageUploadView.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//
import SwiftUI

struct ImageUploadView: View {
    @Binding var images: [UIImage]
    @Binding var showImagePicker: Bool
    
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
                
                addPhotoButton
            }
        }
    }
    
    private var addPhotoButton: some View {
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
