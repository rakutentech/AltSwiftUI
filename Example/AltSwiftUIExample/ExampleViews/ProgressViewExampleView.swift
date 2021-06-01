//
//  ProgressViewExampleView.swift
//  AltSwiftUIExample
//
//  Created by Tsuchiya, Hiroma | Hiroma | TID on 2021/05/27.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct ProgressViewExampleView: View {
    var viewStore = ViewValues()
    @State private var progressValue: Float = 0.7
    
    var body: View {
        VStack {
            HStack {
                ProgressView()
                ProgressView("Now loading...")
            }
            
            Divider()
            
            Button {
                progressValue = Float.random(in: 0..<1)
            } label: { () -> View in
                Text("Set a random progress value")
            }
            
            Text(String(progressValue))

            ProgressView(progressValue)
                .frame(maxWidth: .infinity)
            ProgressView("Downloading...", value: progressValue, total: 1.0)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
