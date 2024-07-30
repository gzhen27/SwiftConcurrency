//
//  DoCatchTryThrowsSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/30/24.
//

import SwiftUI

class DoCatchTryThrowsDataManager {
    func getContent() -> String {
       return "Updated Content"
    }
}

class DoCatchTryThrowsViewModel: ObservableObject {
    @Published var content = "Initial Content"
    
    let manager = DoCatchTryThrowsDataManager()
    
    func fetch() {
        content = manager.getContent()
    }
}

struct DoCatchTryThrowsSection: View {
    @StateObject private var viewModel = DoCatchTryThrowsViewModel()
    
    var body: some View {
        Text(viewModel.content)
            .font(.title)
            .padding()
            .frame(width: 300, height: 200)
            .background(.red.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                viewModel.fetch()
            }
    }
}

#Preview {
    DoCatchTryThrowsSection()
}
