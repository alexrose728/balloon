//
//  ColorChip.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//
import SwiftUI

struct ColorChip: View {
    let colorName: String
    let isSelected: Bool
    let action: () -> Void
    
    private var color: Color {
        switch colorName.lowercased() {
        case "red": return .red
        case "blue": return .blue
        case "gold": return .yellow
        case "silver": return .gray
        case "pink": return .pink
        case "black": return .black
        case "white": return .white
        case "green": return .green
        case "purple": return .purple
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(colorName)
                .font(.caption)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? color : Color(.systemGray5)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
