//
//  TaskSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

@Observable
class TaskSectionViewModel {
    var image: Image?
    
    func fetchImage() async throws {
        guard let url = URL(string: "https://cdn2.thecatapi.com/images/a5l.jpg") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

struct TaskSection: View {
    @State private var viewModel = TaskSectionViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .onAppear {
            Task {
                try? await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    TaskSection()
}
