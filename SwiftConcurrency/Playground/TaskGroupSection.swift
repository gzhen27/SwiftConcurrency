//
//  TaskGroupSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

class TaskGroupSectionDataManager {
    func fetchImagesWithAsyncLet() async throws-> [ImageInfo] {
        async let imageTask01 = fetchImage()
        async let imageTask02 = fetchImage()
        async let imageTask03 = fetchImage()
        async let imageTask04 = fetchImage()
        
        return await [
            try imageTask01,
            try imageTask02,
            try imageTask03,
            try imageTask04
        ]
    }
    
    func fetchImagesWithTaskGroup() async throws -> [ImageInfo] {
        let maxCount = 6
        var imageData: [ImageInfo] = []
        imageData.reserveCapacity(maxCount)
        
        try await withThrowingTaskGroup(of: ImageInfo.self) { [unowned self] group in
            Range(1...maxCount).forEach { _ in
                group.addTask {
                    // For testing purpose only.
                    // use try will throw error out the whole group even just on failed call
                    // use try? if you want to return the success calls, and ignore the failed call
                    try await self.fetchImage()
                }
            }
            
            // order is not guaranteed. First In First Serve
            for try await imageInfo in group {
                imageData.append(imageInfo)
            }
        }
        
        return imageData
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
            self.imageData = try await manager.fetchImagesWithTaskGroup()
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
