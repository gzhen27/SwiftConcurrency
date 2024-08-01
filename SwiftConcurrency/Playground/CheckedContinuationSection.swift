//
//  CheckedContinuationSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/1/24.
//

import SwiftUI

class CheckedContinuationNetworkManager {
    func getData(from url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            throw error
        }
    }
}

@Observable
class CheckedContinuationViewModel {
    var image: Image?
    private let manager = CheckedContinuationNetworkManager()
    
    func load() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        do {
            let data = try await manager.getData(from: url)
            if let image = UIImage(data: data) {
                self.image = Image(uiImage: image)
            } else {
                print("Can't load image")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct CheckedContinuationSection: View {
    @State private var viewModel = CheckedContinuationViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    CheckedContinuationSection()
}
