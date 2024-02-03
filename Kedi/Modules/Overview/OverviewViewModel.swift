//
//  OverviewViewModel.swift
//  Kedi
//
//  Created by Saffet Emin Reisoğlu on 2/2/24.
//

import Foundation

final class OverviewViewModel: ObservableObject {
    
    enum State {
        case loading
        case empty
        case error(Error)
        case data
    }
    
    private let apiService = APIService.shared
    
    @Published var state: State = .loading
    
    @Published var items = [OverviewItem]()
    
    init() {
        Task {
            await fetchOverview { [weak self] error in
                guard let self else {
                    return
                }
                if let error {
                    state = .error(error)
                } else {
                    state = .data
                }
            }
        }
    }
    
    @MainActor
    private func fetchOverview(completion: ((Error?) -> Void)? = nil) async {
        do {
            let data = try await apiService.request(
                type: RCOverviewModel.self,
                endpoint: .overview
            )
            items = [
                .init(type: .mrr, value: "\(data?.mrr?.formatted(.currency(code: "USD")) ?? "")"),
                .init(type: .subsciptions, value: "\(data?.activeSubscribersCount ?? 0)"),
                .init(type: .trials, value: "\(data?.activeTrialsCount ?? 0)"),
                .init(type: .revenue, value: "\(data?.revenue?.formatted(.currency(code: "USD")) ?? "")"),
                .init(type: .users, value: "\(data?.activeUsersCount ?? 0)"),
                .init(type: .installs, value: "\(data?.installsCount ?? 0)")
            ]
            completion?(nil)
        } catch {
            completion?(error)
        }
    }
}