//
//  LinkExampleView.swift
//  AltSwiftUIExample
//
//  Created by Chan, Chengwei on 2021/05/28.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct LinkExampleView: View {
    var viewStore = ViewValues()
    var body: View {
        VStack(spacing: 20) {
            Link("View Our Terms of Service",
                 destination: URL(string: "https://www.example.com/TOS.html")!)
            
            Link("Link",
                 destination: URL(string: "https://www.example.com/TOS.html")!)
                .font(.headline)
                .foregroundColor(.red)
            
            if #available(iOS 14.0, *) {
                Link(destination: URL(string: "https://www.example.com/TOS.html")!) {
                    Label("Rain", systemImage: "cloud.rain")
                }
            }
        }
    }
}
