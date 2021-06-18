//
//  PathExampleView.swift
//  AltSwiftUIExample
//
//  Created by Nodehi, Jabbar on 2021/06/03.
//  Copyright © 2021 Rakuten Travel. All rights reserved.
//

import Foundation

import AltSwiftUI
import UIKit

struct PathExampleView: View {
    var viewStore = ViewValues()
    
    @State var toggle = true
    
    let correctY: CGFloat = 50
    let messedUpY: CGFloat = 250
    
    let correctX: CGFloat = 20
    let messedUpX: CGFloat = 56
    
    var height: CGFloat = 50
        var width: CGFloat = 50

        @State private var percentage: CGFloat = .zero
    
    var body: View {

        VStack {
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: height/2))
                path.addLine(to: CGPoint(x: width/2, y: height))
                path.addLine(to: CGPoint(x: width, y: 0))
            }
            .trim(from: 0, to: percentage)
            .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            .animation(.easeOut(duration: 2.0))
            .padding(.bottom, 30)
            .onAppear {
                self.percentage = 1.0
            }
            .onDisappear {
                self.percentage = .zero
            }
            
            Button("Mess It Up") {
                withAnimation { self.toggle.toggle() }
            }
            .padding(.bottom, 30)
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: toggle ? correctY : messedUpY))
                    path.addQuadCurve(to: CGPoint(x: 50, y: 0), control: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 300, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 350, y: toggle ? correctY : messedUpY), control: CGPoint(x: 350, y: 0))
                    path.addLine(to: CGPoint(x: 350, y: 600))
                    path.addQuadCurve(to: CGPoint(x: 300, y: 650), control: CGPoint(x: 350, y: 650))
                    path.addLine(to: CGPoint(x: 50, y: 650))
                    path.addQuadCurve(to: CGPoint(x: 0, y: 600), control: CGPoint(x: 0, y: 650))
                    path.addLine(to: CGPoint(x: 0, y: toggle ? correctY : messedUpY))
                }
                .fill(.black)
                .strokeBorder(.red)

                Path { path in
                    path.move(to: CGPoint(x: toggle ? correctX : messedUpX, y: toggle ? correctY : messedUpY))
                    path.addQuadCurve(to: CGPoint(x: 50, y: 20), control: CGPoint(x: toggle ? correctX : messedUpX, y: 20))

                    path.addLine(to: CGPoint(x: 90, y: 20))
                    path.addQuadCurve(to: CGPoint(x: 100, y: 30), control: CGPoint(x: 100, y: 20))
                    path.addQuadCurve(to: CGPoint(x: 120, y: correctY), control: CGPoint(x: 100, y: toggle ? correctY : messedUpY))
                    path.addLine(to: CGPoint(x: 230, y: toggle ? correctY : messedUpY))
                    path.addQuadCurve(to: CGPoint(x: 250, y: 30), control: CGPoint(x: 250, y: toggle ? correctY : messedUpY))
                    path.addQuadCurve(to: CGPoint(x: 260, y: 20), control: CGPoint(x: 250, y: 20))

                    path.addLine(to: CGPoint(x: 300, y: 20))
                    path.addQuadCurve(to: CGPoint(x: 330, y: toggle ? correctY : messedUpY), control: CGPoint(x: 330, y: 20))
                    path.addLine(to: CGPoint(x: 330, y: 600))
                    path.addQuadCurve(to: CGPoint(x: 300, y: 630), control: CGPoint(x: 330, y: 630))
                    path.addLine(to: CGPoint(x: 50, y: 630))
                    path.addQuadCurve(to: CGPoint(x: toggle ? correctX : messedUpX, y: 600), control: CGPoint(x: toggle ? correctX : messedUpX, y: 630))
                    path.addLine(to: CGPoint(x: toggle ? correctX : messedUpX, y: toggle ? correctY : messedUpY))
                }
                .fill(.gray)
                .strokeBorder(.red)
            }
        }
    }
    
}
