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
            LazyGridView() {
                Text("First")
                Text("First Sec sdfusdfk jsdf isdjfosi asdasd asdasd asd asdasd asdas dasdasd asd a")
    //                .frame(height: 50)
                Text("First")
                    .frame(height: expand ? 200 : 100)
                    .background(.red)
                Text("First")
                Text("First")
                Text("First")
            }
        }
    }
}
