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
    var image2: Image?
    
    func fetchImage() async throws {
        // empty the previous image for testing.
//        self.image = nil
        
        guard let url = URL(string: "https://cdn2.thecatapi.com/images/a5l.jpg") else { return }
        
        do {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let uiImage = UIImage(data: data) {
                // simulate it takes 5 seconds to download the image

                await MainActor.run {
                    self.image = Image(uiImage: uiImage)
                    print("Updated image")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async throws {
        guard let url = URL(string: "https://cdn2.thecatapi.com/images/a21.jpg") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image2 = Image(uiImage: uiImage)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskHomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationLink("Show Details") {
                    TaskSection()
                }
            }
        }
    }
}

struct TaskSection: View {
    @State private var viewModel = TaskSectionViewModel()
    @State private var fetchImageTask: Task<(), Never>? = nil
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
            
            if let image2 = viewModel.image2 {
                image2
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
            }
        }
        .task {
            try? await viewModel.fetchImage()
        }
//        .onAppear {
//            fetchImageTask = Task {
//                print("Task 01 \(Thread.current)")
//                print("Task 01 \(Task.currentPriority)")
//                try? await viewModel.fetchImage()
//                
//                // fetchImage2() will have to wait until the fetchImage() is completed.
//                // try? await viewModel.fetchImage2()
//            }
//            //
//            //            Task {
//            //                print("Task 02 \(Thread.current)")
//            //                print("Task 02 \(Task.currentPriority)")
//            //                try? await viewModel.fetchImage2()
//            //            }
//            
//            //            Task(priority: .high) {
//            //                // only the .high priority sleep for 2 seconds
//            ////                try? await Task.sleep(nanoseconds: 2_000_000_000)
//            //                await Task.yield()
//            //                print("high : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            //            Task(priority: .userInitiated) {
//            //                print("userInitiated : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            //            Task(priority: .medium) {
//            //                print("medium : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            //            Task(priority: .utility) {
//            //                print("utility : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            //            Task(priority: .low) {
//            //                print("low : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            //            Task(priority: .background) {
//            //                print("background : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //            }
//            
//            
//            //            Task(priority: .userInitiated) {
//            //                print("userInitiated : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //
//            //                // For testing purpose only, use TaskGroup.
//            //                Task.detached {
//            //                    print("detached : \(Thread.current) + \(Task.currentPriority)  + \(Task.currentPriority.rawValue)")
//            //                }
//            //            }
//        }
//        .onDisappear {
//            fetchImageTask?.cancel()
//            print("Fetch Image Task is cancel")
//        }
    }
}

#Preview {
    TaskSection()
}
