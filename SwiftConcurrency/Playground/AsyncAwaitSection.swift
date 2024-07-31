//
//  AsyncAwaitSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 7/31/24.
//

import SwiftUI

@Observable
class AsyncAwaitViewModel {
    var items: [String] = []
    
    func updateItemsInMainThread() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.items.append("new item 01: \(Thread.current)")
        }
    }
    
    func updateItemsInOtherThread() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let item = "new item 02: \(Thread.current)"
            DispatchQueue.main.async {
                self.items.append(item)
                self.items.append("new item 03: \(Thread.current)")
            }
        }
    }
    
    func updateItems() async {
        //Class property 'current' is unavailable from asynchronous contexts; Thread.current cannot be used from async contexts.; this is an error in Swift 6
        self.items.append("Itme 01 : \(Thread.current)")
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        //Class property 'current' is unavailable from asynchronous contexts; Thread.current cannot be used from async contexts.; this is an error in Swift 6
        self.items.append("Itme 02 : \(Thread.current)")
    }
}

struct AsyncAwaitSection: View {
    @State private var viewModel = AsyncAwaitViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.self) { item in
                Text(item)
            }
        }
        .onAppear {
//            viewModel.updateItemsInMainThread()
//            viewModel.updateItemsInOtherThread()
            Task {
                await viewModel.updateItems()
            }
        }
    }
}

#Preview {
    AsyncAwaitSection()
}
