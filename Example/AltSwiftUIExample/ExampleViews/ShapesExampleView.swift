//
//  ShapesExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/09/24.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI

struct ShapesExampleView: View {
    var viewStore = ViewValues()
    @State private var goBig: Bool = false
    
    var body: View {
        VStack {
            Button(action: {
                withAnimation {
                    goBig.toggle()
                }
            }, label: {
                Text("PRESS ME")
            })
            .padding([.top, .bottom], 50)
            
            RoundedRectangle(cornerRadius: goBig ? 20 : 10)
                .background(.yellow)
                .fill(goBig ? .purple : .green)
                .strokeBorder(goBig ? .pink : .purple, lineWidth: goBig ? 8 : 3)
                .frame(width: goBig ? 300 : 200, height: 200)
        }
    }
}
