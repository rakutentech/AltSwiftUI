//
//  GradientExampleView.swift
//  AltSwiftUIExample
//
//  Created by yang.q.wang on 2021/5/26.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import AltSwiftUI
import UIKit

struct GradientExampleView: View {
    var viewStore = ViewValues()
    let width: CGFloat = 150
    let height: CGFloat = 150
    @State var isColor = true
    @State var startPoint: CGPoint = .top
    @State var endPoint: CGPoint = .bottom
    @State var startRadius: CGFloat = 10
    @State var endRadius: CGFloat = 30
    @State var colors:[Color] = [.red, .yellow, .green, .blue, .purple]
    var body: View {
        VStack(alignment: .center, spacing: 10) { () -> View in
            Text("Hello World!").background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint:self.startPoint, endPoint:self.endPoint))
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .animation(.linear(duration: 1))
            LinearGradient(gradient: Gradient(colors: self.colors), startPoint:self.startPoint, endPoint:self.endPoint)
                .frame(width: width, height: height).clipShape(Circle())
                .animation(.linear(duration: 1))

            RadialGradient(gradient: Gradient(colors: self.colors), center: self.startPoint, startRadius: startRadius, endRadius: endRadius)
                .frame(width: width, height: height)
                .animation(.linear(duration: 1))

            Ellipse().background(LinearGradient(gradient: Gradient(colors: self.colors), startPoint:self.startPoint, endPoint:self.endPoint))
                .frame(width: width, height: 120)
                .clipShape(Ellipse())
                .animation(.linear(duration: 1))
            HStack{
                Button("Colors Change") {
                    self.isColor = !self.isColor
                    if self.isColor {
                        colors = [.red, .yellow, .green, .blue, .purple]
                    }else{
                        colors = [.purple, .blue, .green, .yellow, .red]
                    }
                }
                Button("Point Change") {
                    if self.startPoint == .bottom {
                        self.startPoint = .top
                        self.endPoint = .bottom
                    }else{
                        self.startPoint = .bottom
                        self.endPoint = .top
                    }
                    if endRadius <= width {
                        endRadius += 40
                    }else{
                        endRadius = 30
                    }
                    
                }
            }
        }
    }
}
