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
    @State var showButtons = true
    @State var show = false
    @State var expand = false
    @State var swap = false
    @State var newData = false
    
    var body: View {
        LazyVStack {
            Button("show / hide buttons") {
                withAnimation {
                    showButtons.toggle()
                }
            }
            if showButtons {
                Button("show") {
                    withAnimation {
                        show.toggle()
                    }
                }
                Button("expand") {
                    withAnimation {
                        expand.toggle()
                    }
                }
                Button("swap") {
                    withAnimation {
                        swap.toggle()
                    }
                }
                Button("newData") {
                    withAnimation {
                        newData.toggle()
                    }
                }
            }
            ScrollView {
                VStack {
                    if !swap {
                        Text("Outside lazy stack")
                            .frame(height: 100)
                            .background(.green)
                    }
                    if show {
                        LazyStackContentView(expand: $expand, newData: $newData)
                    }
                    if swap {
                        Text("Outside lazy stack")
                            .frame(height: 100)
                            .background(.green)
                    }
                    Text("Outside END")
                }
            }
        }
    }
}

struct LazyStackContentView: View {
    @Binding var expand: Bool
    @Binding var newData: Bool
    @State var showSecondLazyHStack = false
    var body: View {
        LazyVStack {
            if !newData {
                ForEach(0..<2) {_ in
                    Text("Yolo")
                }
                Text("First")
                Text("First Sec sdfusdfk jsdf isdjfosi asdasd asdasd asd asdasd asdas dasdasd asd a")
                Text("First")
                    .frame(height: expand ? 30 : 250)
                    .background(.red)
                Text("First")
                HStack {
                    Text("First")
                        .frame(height: 200)
                        .background(.blue)
                    Text("First2")
                        .frame(height: 200)
                        .background(.pink)
                }
                Group {
                    ScrollView(.horizontal) {
                        VStack(alignment: .leading) {
                            Text("LazyHStack below")
                                .font(.headline)
                            HStack(spacing: 5) {
                                Text("OutLazyHStack")
                                LazyHStack(spacing: 10) {
                                    ForEach(0..<8) { i in
                                        Text("Element \(i)")
                                    }
                                    Text("Last Element")
                                }
                                .frame(height: 50)
                                .background(.purple)
                            }
                        }
                    }
                    ScrollView(.horizontal) {
                        VStack(alignment: .leading) {
                            Text("LazyHStack 2 below")
                                .font(.headline)
                            Button("Show second LazyHStack") {
                                withAnimation {
                                    showSecondLazyHStack.toggle()
                                }
                            }
                            HStack(spacing: 5) {
                                Text("OutLazyHStack")
                                if showSecondLazyHStack {
                                    LazyHStack(spacing: 10) {
                                        ForEach(0..<8) { i in
                                            Text("Element \(i)")
                                        }
                                        Text("Last Element")
                                    }
                                    .frame(height: 50)
                                }
                            }
                        }
                    }
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
            } else {
                newDataViews
            }
        }
    }
    
    @ViewBuilder var newDataViews: View {
        Text("new Data")
        Text("Neere")
            .frame(height: 100)
        Button("Hello") {}
        Text("Second")
        Text("Third")
            .frame(height: expand ? 20 : 40)
            .background(.red)
        ForEach(0..<12) { _ in
            Text("New For Each")
                .frame(height: 50)
        }
    }
    
    var viewStore = ViewValues()
}
