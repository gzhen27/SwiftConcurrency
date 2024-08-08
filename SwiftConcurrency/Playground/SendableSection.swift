//
//  SendableSection.swift
//  SwiftConcurrency
//
//  Created by G Zhen on 8/8/24.
//

import SwiftUI

actor SendableSectionDataManager {
    
    func updateDB(user: UserInfoV2) {
        
    }
    
}

struct UserInfo: Sendable {
    var name: String
}

final class UserInfoV2: @unchecked Sendable {
    private var name: String
    private let queue = DispatchQueue(label: "UserInfoV2Lock")
    
    init(name: String) {
        self.name = name
    }
    
    func updateName(name: String) {
        queue.async {
            self.name = name
        }
    }
}

@Observable
class SendableSectionViewModel {
    
    private let manager = SendableSectionDataManager()
    
    func updateInfo() async {
        await manager.updateDB(user: UserInfoV2(name: "admin"))
    }
    
}


struct SendableSection: View {
    @State private var viewModel = SendableSectionViewModel()
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .task {
            await viewModel.updateInfo()
        }
    }
}

#Preview {
    SendableSection()
}
