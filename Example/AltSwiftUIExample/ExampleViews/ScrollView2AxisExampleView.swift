//
//  ScrollView2AxisExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2021/01/12.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct ScrollView2AxisExampleView: View {
    var viewStore = ViewValues()
    var body: View {
        ScrollView(.both) {
            VStack {
                HStack {
                    Text("Start")
                        .lineLimit(1)
                    Color.green
                        .frame(width: 100, height: 100)
                        .padding(.leading, 250)
                    Text("trailing text")
                        .lineLimit(1)
                        .padding(.leading, 250)
                }
                Color.red
                    .frame(width: 100, height: 100)
                    .padding(.top, 500)
                Text("bottom text")
                    .padding(.top, 500)
            }
        }
    }
}
