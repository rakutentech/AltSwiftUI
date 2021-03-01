//
//  MenuExampleView.swift
//  AltSwiftUIExample
//
//  Created by Chan, Chengwei on 2021/03/01.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct MenuExampleView: View {
    var viewStore = ViewValues()
    
    @State private var update = false
    
    var body: View {
        VStack {
            if #available(iOS 14.0, *) {
                Menu {
                    Button("Option 1", action: { print("click option 1") })
                    Button("Option 2", action: {})
                    Button("Option 3", action: {})
        
                    Menu("lv2 Menu") {
                        ForEach(0..<20) { index in
                            Button("Option_\(index)", action: {})
                        }
                    }
                } label: { () -> View in
                    VStack {
                        Text("Menu")
                    }
                }
            }
        }
    }
}
