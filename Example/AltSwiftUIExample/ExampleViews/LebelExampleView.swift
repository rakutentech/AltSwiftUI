//
//  LebelExampleView.swift
//  AltSwiftUIExample
//
//  Created by Chan, Chengwei on 2021/05/24.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct LabelExampleView: View {
    var viewStore = ViewValues()
    var body: View {
        VStack(spacing: 20) {
            Label("Lamen", image: "icon")
            
            Label {
                Text("fullName")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("(nickName)")
                    .font(.body)
                    .foregroundColor(.primary)
            } icon: {
                Circle()
                    .fill(.blue)
                    .frame(width: 44, height: 44)
            }
            
            Label {
                Text("fullName")
                    .font(.body)
                    .foregroundColor(.primary)
                Text("(nickName)")
                    .font(.body)
                    .foregroundColor(.primary)
            } icon: {
                Circle()
                    .fill(.blue)
                    .frame(width: 44, height: 44)
            }
            .labelStyle(TitleOnlyLabelStyle())
            
            if #available(iOS 14.0, *) {
                Label("Rain", systemImage: "cloud.rain")
            }
        
            if #available(iOS 14.0, *) {
                VStack {
                    Label("Rain", systemImage: "cloud.rain")
                    Label("Snow", systemImage: "snow")
                    Label("Sun", systemImage: "sun.max")
                }
                .labelStyle(IconOnlyLabelStyle())
            }
        }
    }
}
