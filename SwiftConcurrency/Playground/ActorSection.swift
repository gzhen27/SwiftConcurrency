//
//  ActorSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/6/24.
//

import SwiftUI

class SharedDataManager {
    // ONLY use Singleton for testing purpose
    static let shared = SharedDataManager()
    
    var data: [String] = []
    
    private init() {}
    
    // This function will casue data race.
    // Different threads acces the class at the same time
    //    func insertRandomData() -> String? {
    //        data.append(UUID().uuidString)
    //        print(Thread.current)
    //        return data.randomElement()
    //    }
    
    // MARK: Solution without using Actor, create a specific queue to when accsing the data object.
    private let queue = DispatchQueue(label: "SharedDataManagerQueue")
    
    func insertRandomDataWithCompletionHandler(completionHandler: @escaping (_ content: String?) -> ()) {
        queue.async {
            self.data.append(UUID().uuidString)
            print(Thread.current)
            completionHandler(self.data.randomElement())
        }
    }
}

actor SharedDataManagerActor {
    // ONLY use Singleton for testing purpose
    static let shared = SharedDataManagerActor()
    
    var data: [String] = []
    nonisolated let example = UUID().uuidString
    
    private init() {}
    
    func insertRandomData() -> String? {
        data.append(UUID().uuidString)
        print(Thread.current)
        return data.randomElement()
    }
}

struct FirstView: View {
    let manager = SharedDataManagerActor.shared
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
        .onAppear {
            print("try out the nonisolated keyword \(manager.example)")
        }
        .onReceive(timer, perform: { _ in
            /*
            DispatchQueue.global(qos: .background).async {
                manager.insertRandomDataWithCompletionHandler { content in
                    if let content = content {
                        DispatchQueue.main.async {
                            self.content = content
                        }
                    }
                }
                
//                if let data = manager.insertRandomData() {
//                    DispatchQueue.main.async {
//                        self.content = data
//                    }
//                }
            }
             */
            
            Task {
                if let content = await manager.insertRandomData() {
                    await MainActor.run {
                        self.content = content
                    }
                }
            }
        })
    }
}

struct SecondView: View {
    let manager = SharedDataManagerActor.shared
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
            /*
            DispatchQueue.global(qos: .default).async {
                manager.insertRandomDataWithCompletionHandler { content in
                    if let content = content {
                        DispatchQueue.main.async {
                            self.content = content
                        }
                    }
                }
                
//                if let data = manager.insertRandomData() {
//                    DispatchQueue.main.async {
//                        self.content = data
//                    }
//                }
            }
             */
            
            Task {
                if let content = await manager.insertRandomData() {
                    await MainActor.run {
                        self.content = content
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
