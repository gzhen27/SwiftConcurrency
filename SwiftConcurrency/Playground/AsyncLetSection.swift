//
//  AsyncLetSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

@Observable
class AsyncLetViewModel {
    var imageData: [ImageInfo] = []
    
    func fetch() async throws -> ImageInfo {
        let url = URL(string: "https://picsum.photos/300")!
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else { throw URLError(.badURL) }
            return ImageInfo(image: Image(uiImage: uiImage))
        } catch  {
            throw error
        }
        
        
    }
}

struct AsyncLetSection: View {
    @State private var viewModel = AsyncLetViewModel()
    let gridItems = [GridItem(), GridItem()]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 12, content: {
                    ForEach(viewModel.imageData) { imageInfo in
                        imageInfo.image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(height: 150)
                    }
                })
            }
            .task {
                do {
                    async let imageTask01 = viewModel.fetch()
                    async let imageTask02 = viewModel.fetch()
                    async let imageTask03 = viewModel.fetch()
                    async let imageTask04 = viewModel.fetch()
                    viewModel.imageData = await [try imageTask01, try imageTask02, try imageTask03, try imageTask04]
                } catch {
                    print(error.localizedDescription)
                }
            }
            .navigationTitle("Async Let")
        }
    }
}

#Preview {
    AsyncLetSection()
}
