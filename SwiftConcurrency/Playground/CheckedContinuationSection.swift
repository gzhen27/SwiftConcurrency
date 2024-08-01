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
    
    func getDataWithCompletionHandler(from url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        }
    }
    
    private func getHeartImage(completionHandler: @escaping (_ image: Image) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            let image = Image(systemName: "heart")
            completionHandler(image)
        }
    }
    
    func getHeartImage() async throws -> Image {
        return await withCheckedContinuation { continuation in
            getHeartImage { image in
                continuation.resume(returning: image)
            }
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
            let data = try await manager.getDataWithCompletionHandler(from: url)
            if let image = UIImage(data: data) {
                self.image = Image(uiImage: image)
            } else {
                print("Can't load image")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadHeart() async {
//        manager.getHeartImage { [weak self] image in
//            self?.image = image
//        }
        do {
            self.image = try await manager.getHeartImage()
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
//            await viewModel.load()
            await viewModel.loadHeart()
        }
    }
}

#Preview {
    CheckedContinuationSection()
}
