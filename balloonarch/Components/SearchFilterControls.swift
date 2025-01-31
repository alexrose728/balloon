//
//  SearchFilterControls.swift
//  balloonarch
//
//  Created by Rose, Alex on 2/1/25.
//
import SwiftUI

struct SearchFilterControls: View {
    @ObservedObject var vm: SearchViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Search Text Field
            TextField("Search balloon arches...", text: $vm.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            // Color Filters
            VStack(alignment: .leading) {
                Text("Filter by Colors:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(ColorOptions.allCases, id: \.self) { color in
                            ColorChip(
                                colorName: color.rawValue,
                                isSelected: vm.selectedColors.contains(color.rawValue),
                                action: { vm.toggleColorSelection(color.rawValue) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Radius Filter
            VStack(alignment: .leading) {
                Text("Search Radius: \(Int(vm.searchRadius)) miles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: $vm.searchRadius,
                    in: 1...100,
                    step: 1
                )
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}


// Add this extension if missing
extension Color {
    init(_ uiColor: UIColor) {
        self.init(uiColor: uiColor)
    }
}

enum ColorOptions: String, CaseIterable {
    case red = "Red"
    case blue = "Blue"
    case gold = "Gold"
    case silver = "Silver"
    case pink = "Pink"
    case black = "Black"
    case white = "White"
    case green = "Green"
    case purple = "Purple"
}

extension ColorOptions {
    var colorValue: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .gold: return .yellow
        case .silver: return .gray
        case .pink: return .pink
        case .black: return .black
        case .white: return .white
        case .green: return .green
        case .purple: return .purple
        }
    }
}
