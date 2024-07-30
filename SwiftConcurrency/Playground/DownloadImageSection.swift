//
//  DownloadImageSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/30/24.
//

import SwiftUI

class DownloadImageImageLoader {
    func fetch() async throws -> Image? {
        let url = URL(string: "https://cdn2.thecatapi.com/images/a5l.jpg")!
        
        do {
            let (data, res) = try await URLSession.shared.data(from: url)
            return handleImageResponse(data: data, response: res)
        } catch {
            throw error
        }
    }
    
    private func handleImageResponse(data: Data?, response: URLResponse?) -> Image? {
        guard 
            let data = data,
            let image = UIImage(data: data),
            let res = response as? HTTPURLResponse,
            res.statusCode >= 200 && res.statusCode < 300
        else {
            return nil
        }
        
        return Image(uiImage: image)
    }
}

@Observable
class DownloadImageViewModel {
    var image: Image?
    
    let loader = DownloadImageImageLoader()
    func fetch() async {
        let image = try? await loader.fetch()
        
        await MainActor.run {
            self.image = image
        }
    }
}


struct DownloadImageSection: View {
    @State private var viewModel = DownloadImageViewModel()
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
            }
        }
        .task {
            await viewModel.fetch()
        }
    }
}

#Preview {
    DownloadImageSection()
}
