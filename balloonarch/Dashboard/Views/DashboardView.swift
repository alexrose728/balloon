//
//  DashboardView.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import SwiftUI
import Charts
import SDWebImageSwiftUI


struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject var vm = DashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Quick Stats Overview
                    StatsGridView(
                        activeListings: vm.activeListingsCount,
                        totalEarnings: vm.totalEarnings,
                        completedOrders: vm.completedOrdersCount
                    )
                    .padding(.horizontal)
                    
                    // Earnings Chart
//                    EarningsChartView(earningsData: vm.earningsData)
//                        .frame(height: 200)
//                        .padding(.horizontal)
                    
                    // Recent Activity
                    RecentActivitySection(
                        recentListings: vm.recentListings,
                        recentPurchases: vm.recentPurchases
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .refreshable { await vm.refreshData() }
            .overlay {
                if vm.isLoading {
                    ProgressView()
                }
            }
            .alert("Error", isPresented: $vm.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.errorMessage)
            }
        }
        .task { await vm.loadInitialData() }
    }
}

// MARK: - Subcomponents
private struct StatsGridView: View {
    let activeListings: Int
    let totalEarnings: Double
    let completedOrders: Int
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            StatCard(title: "Active Listings", value: "\(activeListings)", icon: "balloon")
            StatCard(title: "Total Earnings", value: totalEarnings.formatted(.currency(code: "USD")), icon: "dollarsign.circle")
            StatCard(title: "Completed Orders", value: "\(completedOrders)", icon: "checkmark.seal")
            QuickActionButtons()
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2.bold())
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

//private struct EarningsChartView: View {
//    let earningsData: [DailyEarnings]
//    
//    var body: some View {
//        Chart(earningsData) { data in
//            BarMark(
//                x: .value("Date", data.date, unit: .day),
//                y: .value("Earnings", data.amount)
//            )
//            .foregroundStyle(Color.blue.gradient)
//        }
//        .chartXAxis {
//            AxisMarks(values: .stride(by: .day)) { value in
//                AxisGridLine()
//                AxisValueLabel(format: .dateTime.day().month(.narrow))
//            }
//        }
//        .chartYAxis {
//            AxisMarks { value in
//                AxisGridLine()
//                AxisValueLabel(
//                    value.as(Double.self)?.formatted(.currency(code: "USD")) ?? ""
//                )
//            }
//        }
//    }
//}

private struct RecentActivitySection: View {
    let recentListings: [BalloonArch]
    let recentPurchases: [Purchase]
    
    var body: some View {
        VStack(spacing: 20) {
            RecentActivityList(title: "Recent Listings", items: recentListings) { arch in
                VStack(alignment: .leading) {
                    Text(arch.colors.joined(separator: ", "))
                        .font(.subheadline)
                    Text(arch.price.formatted(.currency(code: "USD")))
                        .font(.caption)
                }
            }
            
            RecentActivityList(title: "Recent Purchases", items: recentPurchases) { purchase in
                VStack(alignment: .leading) {
                    Text(purchase.archId)
                        .font(.subheadline)
                    Text(purchase.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
    }
}

private struct RecentActivityList<Item: Identifiable, Content: View>: View {
    let title: String
    let items: [Item]
    let content: (Item) -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(items) { item in
                        content(item)
                            .padding()
                            .frame(width: 150)
                            .background(Color(.tertiarySystemBackground))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct QuickActionButtons: View {
    var body: some View {
        NavigationLink {
            Text("New Listing View")
        } label: {
            Label("New Listing", systemImage: "plus")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
