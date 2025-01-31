//
//  ColorGrid.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//
import SwiftUI

struct ColorGrid: View {
    @Binding var selectedColors: [String]
    private let colors = ["Red", "Blue", "Gold", "Silver", "Pink", "Black", "White", "Green", "Purple"]
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
            ForEach(colors, id: \.self) { color in
                ColorChip(
                    color: color,
                    isSelected: selectedColors.contains(color),
                    action: { toggleSelection(color: color) }
                )
            }
        }
        .padding(.vertical, 8)
    }
    
    private func toggleSelection(color: String) {
        if selectedColors.contains(color) {
            selectedColors.removeAll { $0 == color }
        } else {
            selectedColors.append(color)
        }
    }
}

// MARK: - Preview
//struct ColorGrid_Previews: PreviewProvider {
//    @State static var selectedColors = ["Red", "Blue"]
//    
//    static var previews: some View {
//        ColorGrid(selectedColors: $selectedColors)
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//}
