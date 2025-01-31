//
//  DashboardViewModel.swift
//  balloonarch
//
//  Created by Rose, Alex on 1/31/25.
//
import Firebase
import Combine

struct DailyEarnings: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
}

@MainActor
class DashboardViewModel: ObservableObject {
    // Data
    @Published var recentListings: [BalloonArch] = []
    @Published var recentPurchases: [Purchase] = []
    @Published var earningsData: [DailyEarnings] = []
    
    // State
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    // Services
    private let firestoreService = FirestoreService.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // Computed Properties
    var activeListingsCount: Int { recentListings.count }
    var totalEarnings: Double { earningsData.reduce(0) { $0 + $1.amount } }
    var completedOrdersCount: Int { recentPurchases.count }
    
    init() {
        setupAuthListener()
    }
    
    func loadInitialData() async {
        guard let userId = authService.currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        await fetchAllData(userId: userId)
    }
    
    func refreshData() async {
        guard let userId = authService.currentUser?.id else { return }
        await fetchAllData(userId: userId)
    }
    
    private func setupAuthListener() {
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                guard let self, let userId = user?.id else { return }
                Task { await self.fetchAllData(userId: userId) }
            }
            .store(in: &cancellables)
    }
    
    private func fetchAllData(userId: String) async {
        do {
            async let listings = fetchUserListings(userId: userId)
            async let purchases = fetchRecentPurchases(userId: userId)
            async let earnings = fetchEarningsData(userId: userId)
            
            let (listingsResult, purchasesResult, earningsResult) = try await (listings, purchases, earnings)
            
            recentListings = listingsResult
            recentPurchases = purchasesResult
            earningsData = earningsResult
        } catch {
            handleError(error)
        }
    }
    
    private func fetchUserListings(userId: String) async throws -> [BalloonArch] {
        try await firestoreService.db.collection("balloonArches")
            .whereField("userId", isEqualTo: userId)
            .whereField("availableUntil", isGreaterThan: Date())
            .order(by: "createdAt", descending: true)
            .limit(to: 5)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: BalloonArch.self) }
    }
    
    private func fetchRecentPurchases(userId: String) async throws -> [Purchase] {
        try await firestoreService.db.collection("purchases")
            .whereField("buyerId", isEqualTo: userId)
            .order(by: "purchaseDate", descending: true)
            .limit(to: 5)
            .getDocuments()
            .documents
            .compactMap { try $0.data(as: Purchase.self) }
    }
    
    private func fetchEarningsData(userId: String) async throws -> [DailyEarnings] {
        let snapshot = try await firestoreService.db.collection("purchases")
            .whereField("sellerId", isEqualTo: userId)
            .order(by: "purchaseDate")
            .getDocuments()
        
        let calendar = Calendar.current
        let groupedData = Dictionary(grouping: snapshot.documents) { document -> Date in
            // Add try? and optional handling
            guard let purchase = try? document.data(as: Purchase.self) else {
                return Date.distantPast // Or handle invalid documents differently
            }
            return calendar.startOfDay(for: purchase.purchaseDate)
        }
        
        return groupedData.map { date, documents in
            let total = documents.compactMap { doc in
                try? doc.data(as: Purchase.self).amount
            }.reduce(0, +)
            
            return DailyEarnings(date: date, amount: total)
        }
        .filter { $0.date != Date.distantPast } // Filter out invalid documents
        .sorted { $0.date < $1.date }
    }
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}

struct Purchase: Identifiable, Codable {
    @DocumentID var id: String?
    let archId: String
    let buyerId: String
    let sellerId: String
    let purchaseDate: Date
    let amount: Double
}
