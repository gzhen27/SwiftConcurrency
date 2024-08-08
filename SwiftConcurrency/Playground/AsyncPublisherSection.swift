//
//  AsyncPublisherSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/8/24.
//

import SwiftUI
import Combine

class AsyncPublisherDataManager {
    @Published var data: [String] = []
    
    func fetch() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Item 01")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Item 02")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Item 03")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        data.append("Item 04")
    }
}

@Observable
class AsyncPublisherViewModel {
    var items: [String] = []
    var cancellables = Set<AnyCancellable>()
    private let manager = AsyncPublisherDataManager()
    
    init() {
        addSubscribers()
    }
    
    private func addSubscribers() {
        manager.$data
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.items = data
            }
            .store(in: &cancellables)
    }
    
    func fetch() async {
        await manager.fetch()
    }
    
}


struct AsyncPublisherSection: View {
    @State private var viewModel = AsyncPublisherViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.items, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .task {
           await viewModel.fetch()
        }
    }
}

#Preview {
    AsyncPublisherSection()
}
