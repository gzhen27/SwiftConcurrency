//
//  DoTryCatchThrowsSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/30/24.
//

import SwiftUI

enum PlaygroundError: Error {
    case badResponse
    
    var errorDescription: String {
        switch self {
        case .badResponse:
            "Bad Response"
        }
    }
}

class DoTryCatchThrowsDataManager {
    // isActive is a constant and always be FALSE.
    // getContent() will alwasy return nil value.
    let isActive = false
    
    func getContent() throws -> String {
        guard isActive else { throw PlaygroundError.badResponse }
        return "Updated Content"
    }
}

class DoTryCatchThrowsViewModel: ObservableObject {
    @Published var content = "Initial Content"
    
    let manager = DoTryCatchThrowsDataManager()
    
    func fetch() {
        do {
            self.content = try manager.getContent()
        } catch let error as PlaygroundError {
            self.content = error.errorDescription
        } catch {
            self.content = error.localizedDescription
        }
    }
}

struct DoTryCatchThrowsSection: View {
    @StateObject private var viewModel = DoTryCatchThrowsViewModel()
    
    var body: some View {
        Text(viewModel.content)
            .font(.title)
            .padding()
            .frame(width: 300, height: 500)
            .background(.red.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onTapGesture {
                viewModel.fetch()
            }
    }
}

#Preview {
    DoTryCatchThrowsSection()
}
