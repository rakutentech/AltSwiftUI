//
//  LazyStackExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin | Kevs | TDD on 2021/06/22.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct LazyStackExampleView: View {
    var viewStore = ViewValues()
    @State var expand = false
    
    var body: View {
        VStack {
            Button("expand") {
                withAnimation {
                    expand.toggle()
                }
            }
            ScrollView {
                LazyVStack {
                    Text("First")
                    Text("First Sec sdfusdfk jsdf isdjfosi asdasd asdasd asd asdasd asdas dasdasd asd a")
        //                .frame(height: 50)
                    Text("First")
                        .frame(height: expand ? 200 : 100)
                        .background(.red)
                    Text("First")
                    Text("First")
                        .frame(height: 200)
                        .background(.blue)
                    Text("First2")
                        .frame(height: 200)
                        .background(.blue)
                    Group {
                        Text("Second")
                            .frame(height: 200)
                            .background(.green)
                        Text("Second2")
                            .frame(height: 200)
                            .background(.blue)
                        Text("Second3")
                            .frame(height: 200)
                            .background(.green)
                        Text("Second4")
                            .frame(height: 200)
                            .background(.blue)
                        Text("Second5")
                            .frame(height: 200)
                            .background(.green)
                    }
                }
            }
        }
    }
}
