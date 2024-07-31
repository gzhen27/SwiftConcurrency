//
//  TaskGroupSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

@Observable
class TaskGroupSectionViewModel {
    var imageData: [ImageInfo] = []
    
    func fetch() async {
        imageData.append(ImageInfo(image: Image(systemName: "heart")))
        imageData.append(ImageInfo(image: Image(systemName: "heart.fill")))
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
