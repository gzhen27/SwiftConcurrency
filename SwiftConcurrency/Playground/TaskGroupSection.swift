//
//  TaskGroupSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

class TaskGroupSectionDataManager {
    func fetchImageWithAsyncLet() async throws-> [ImageInfo] {
        async let imageTask01 = fetchImage()
        async let imageTask02 = fetchImage()
        async let imageTask03 = fetchImage()
        async let imageTask04 = fetchImage()
        
        do {
            let result =  await [
                try imageTask01,
                try imageTask02,
                try imageTask03,
                try imageTask04
            ]
            return result
        } catch  {
            throw error
        }
        
    }
    
    private func fetchImage() async throws -> ImageInfo {
        guard let url = URL(string: "https://picsum.photos/300") else { throw URLError(.badURL) }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else { throw URLError(.badServerResponse) }
            return ImageInfo(image: Image(uiImage: uiImage))
        } catch {
            throw error
        }
    }
}

@Observable
class TaskGroupSectionViewModel {
    var imageData: [ImageInfo] = []
    private let manager = TaskGroupSectionDataManager()
    
    func fetch() async {
        do {
            self.imageData = try await manager.fetchImageWithAsyncLet()
        } catch  {
            print(error.localizedDescription)
        }
    }
}

struct TaskGroupSection: View {
    @State private var viewModel = TaskGroupSectionViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(viewModel.imageData) { imageInfo in
                        imageInfo.image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .navigationTitle("TaskGroup")
            .task {
                await viewModel.fetch()
            }
        }
    }
}

#Preview {
    TaskGroupSection()
}
