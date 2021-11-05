//
//  StackUpdateExample.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2021/01/29.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct StackUpdateExample: View {
    var viewStore = ViewValues()
    
    @State private var update = false
    
    var body: View {
        HStack(alignment: .top) {
            VStack {
                Text("Target Stack")
                    .font(Font.body.weight(.bold))
                Text("First text")
                Button("First button") {
                    print("First button print")
                }
                VStack {
                    Text("Text in Stack")
                }
                .background(.red)
                StackUpdateSubview()
            }
            .frame(maxWidth: .infinity)
            
            VStack {
                HStack {
                    Text("Stack To Update")
                        .font(Font.body.weight(.bold))
                    Button("Update") {
                        update.toggle()
                    }
                }
                if update {
                    Text("First text")
                } else {
                    Text("Pre: First text")
                        .background(.blue)
                }
                if update {
                    Button("First button") {
                        print("First button print")
                    }
                } else {
                    Button("Pre: First button") {
                        print("Pre: First button print")
                    }
                }
                if update {
                    VStack {
                        Text("Text in Stack")
                    }
                    .background(.red)
                } else {
                    Text("Shouldn't be here")
                    Text("Shouldn't be here either")
                    ZStack {
                        Text("Much less be here")
                    }
                    VStack {
                        Text("Pre: Text in Stack")
                    }
                    .background(.green)
                }
                if update {
                    StackUpdateSubview()
                } else {
                    StackUpdateSubview()
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct StackUpdateSubview: View {
    var viewStore = ViewValues()
    @State private var title = "Press before update"
    var body: View {
        VStack {
            Button("\(title)") {
                title = "Shouldn't show after update"
            }
        }
    }
}
