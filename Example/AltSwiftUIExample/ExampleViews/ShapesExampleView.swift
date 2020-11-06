//
//  ShapesExampleView.swift
//  AltSwiftUIExample
//
//  Created by Wong, Kevin a on 2020/09/24.
//  Copyright © 2020 Rakuten Travel. All rights reserved.
//

import AltSwiftUI
import UIKit

struct ShapesExampleView: View {
    var viewStore = ViewValues()
    @State private var goBig: Bool = false
    @State private var progress: CGFloat = 0.5
    
    var body: View {
        VStack(spacing: 10) {
            Button(action: {
                goBig.toggle()
            }, label: {
                Text("PRESS ME")
            })
            .padding([.top, .bottom], 20)
            
            RoundedRectangle(cornerRadius: goBig ? 20 : 10)
                .background(.yellow)
                .fill(goBig ? .purple : .green)
                .strokeBorder(goBig ? .pink : .purple, lineWidth: goBig ? 8 : 3)
                .frame(width: goBig ? 300 : 200, height: 200)
            
            Button("Progress") {
                if progress == 0.5 {
                    progress = 1
                } else {
                    progress = 0.5
                }
            }
            HStack {
                Capsule()
                    .frame(width: 50, height: 70)
                    .fill(goBig ? .purple : .green)
                Circle()
                    .frame(width: 50, height: 70)
                    .fill(goBig ? .purple : .green)
                    .stroke(Color.black, style: .init(lineWidth: 8, lineCap: .round))
                Circle()
                    .frame(width: 50, height: 70)
                    .fill(goBig ? .purple : .green)
                    .stroke(Color.black, style: .init(lineWidth: 8, lineCap: .round))
                    .trim(from: 0.25, to: 0.75)
                Circle()
                    .frame(width: 100, height: 70)
                    .stroke(Color.black, style: .init(lineWidth: 8, lineCap: .round))
                    .trim(from: 0.25, to: progress)
                    .animation(.spring())
            }
            
            HStack {
                Ellipse()
                    .frame(width: 50, height: 70)
                    .fill(goBig ? .purple : .green)
                Rectangle()
                    .frame(width: 50, height: 70)
                    .fill(goBig ? .purple : .green)
            }
            
            ShapeExampleNonShapeView(goBig: $goBig)
        }
        .animation(.easeIn(duration: 0.5))
    }
}

struct ShapeExampleNonShapeView: View {
    var viewStore = ViewValues()
    @Binding var goBig: Bool
    var body: View {
        Text("Non shape")
            .frame(width: goBig ? 100 : 50, height: 100)
            .background(goBig ? .purple : .pink)
            .cornerRadius(goBig ? 20 : 5)
            .border(goBig ? .blue : .green, width: goBig ? 10 : 3)
            .padding(.top, 20)
            .onTapGesture {
                print("asd")
            }
    }
}
