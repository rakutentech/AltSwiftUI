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
    
    @State private var toggle = true
    
    private let correctY: CGFloat = 50
    private let messedUpY: CGFloat = 250
    
    private let correctX: CGFloat = 20
    private let messedUpX: CGFloat = 56
    
    private var tickHeight: CGFloat = 50
    private var tickWidth: CGFloat = 50

    @State private var percentage: CGFloat = .zero
    
    var body: View {
        ScrollView {
            VStack {
                
                // MARK: - Tick
                Path { path in
                    path.move(to: CGPoint(x: 0, y: tickHeight/2))
                    path.addLine(to: CGPoint(x: tickWidth/2, y: tickHeight))
                    path.addLine(to: CGPoint(x: tickWidth, y: 0))
                }
                .trim(from: 0, to: percentage)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .animation(.easeOut(duration: 2.0))
                .onAppear {
                    self.percentage = 1.0
                }
                .onDisappear {
                    self.percentage = .zero
                }
                
                // MARK: - Toggle Button
                Button("\(toggle ? "Distort" : "Fix") the 📱 with animation") {
                    withAnimation { self.toggle.toggle() }
                }
                .padding(.vertical, 30)
                
                // MARK: - iPhone Shape
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
                    .fill(.gray)
                    .strokeBorder(.black)

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
                    .fill(.secondary)
                    .strokeBorder(.black)
                }
                
                // MARK: - Text
                Text("Text to mix up UI elements and show that Path occupy actual space.")
                    .foregroundColor(.orange)
                    .padding(.vertical, 20)
                
                // MARK: - Nested red Rectangles
                shrinkingSquares()
                    .strokeBorder(.black)
                    .fill(.red)
            }
            .padding(.vertical, 20)
        }
        .edgesIgnoringSafeArea(.bottom)
        .frame(maxWidth: .infinity)
    }
    
    private func shrinkingSquares() -> Path {
        let size = 400
        let change = 20
        let path = Path()

        for i in stride(from: 1, through: size, by: change) {
            let rect = CGRect(
                x: CGFloat(i),
                y: CGFloat(i),
                width: CGFloat(size) - CGFloat(2 * i),
                height: CGFloat(size) - CGFloat(2 * i)
            )
            path.addRect(rect)
        }
        return path
    }
}
