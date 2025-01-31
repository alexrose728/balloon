//
//  ColorGrid.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//
import SwiftUI

struct ColorGrid: View {
    @Binding var selectedColors: [String]
    private let colorOptions = ["Red", "Blue", "Gold", "Silver", "Pink", "Black", "White", "Green", "Purple"]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
            ForEach(colorOptions, id: \.self) { colorName in
                ColorChip(
                    colorName: colorName,
                    isSelected: selectedColors.contains(colorName),
                    action: { toggleSelection(color: colorName) }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedColors)
        .padding(.vertical, 8)
    }
    
    private func toggleSelection(color: String) {
        withAnimation(.easeInOut) {
            if selectedColors.contains(color) {
                selectedColors.removeAll { $0 == color }
            } else {
                selectedColors.append(color)
            }
        }
    }
}

struct ColorGrid_Previews: PreviewProvider {
    @State static var selectedColors = ["Red", "Blue"]
    
    static var previews: some View {
        ColorGrid(selectedColors: $selectedColors)
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Color Grid Preview")
    }
}
