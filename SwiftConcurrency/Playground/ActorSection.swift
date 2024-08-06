//
//  ActorSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/6/24.
//

import SwiftUI

class SharedDataManager {
    static let shared = SharedDataManager()
    
    var data: [String] = []
    
    private init() {}
    
    func insertRandomData() -> String? {
        data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
}

struct FirstView: View {
    let manager = SharedDataManager.shared
    @State private var content = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.red
                .opacity(0.4)
                .ignoresSafeArea()
            Text(content)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            DispatchQueue.global(qos: .background).async {
                if let data = manager.insertRandomData() {
                    DispatchQueue.main.async {
                        self.content = data
                    }
                }
            }
        })
    }
}

struct SecondView: View {
    let manager = SharedDataManager.shared
    @State private var content = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.4)
                .ignoresSafeArea()
            Text(content)
                .font(.headline)
        }
        .onReceive(timer, perform: { _ in
            DispatchQueue.global(qos: .default).async {
                if let data = manager.insertRandomData() {
                    DispatchQueue.main.async {
                        self.content = data
                    }
                }
            }
        })
    }
}

struct ActorSection: View {
    var body: some View {
        TabView {
            FirstView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            SecondView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}

#Preview {
    ActorSection()
}
