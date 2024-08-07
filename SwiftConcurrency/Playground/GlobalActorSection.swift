//
//  GlobalActorSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/7/24.
//

import SwiftUI

actor GlobalActorSectionDataManager {
    // This is an async function bc it is in an actor.
    func fetch() -> [String] {
        var data:[String] = []
        Range(1...20).forEach { index in
            data.append("Item \(index)")
        }
        return data
    }
}

@Observable
class GlobalActorSectionViewModel {
    
    var data: [String] = []
    private let manager = GlobalActorSectionDataManager()
    
    func fetch() async {
        data = await manager.fetch()
    }
    
}

struct GlobalActorSection: View {
    @State private var viewModel = GlobalActorSectionViewModel()
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.data, id: \.self) { item in
                    Text(item)
                        .font(.headline)
                        .padding()
                }
            }
            .frame(width: 500)
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await viewModel.fetch()
        }
    }
}

#Preview {
    GlobalActorSection()
}
