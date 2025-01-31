//
//  ColorChip.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/2/25.
//


import SwiftUI

struct ColorChip: View {
    let color: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(color)
                .font(.caption)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? Color(color.lowercased()) : Color(.systemGray5)
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(color.lowercased()), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}
