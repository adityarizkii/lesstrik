//
//  MyComponent.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 18/03/25.
//

import SwiftUI


//Progress view melingkar
struct CircularProgressView<Content : View>: View {
    var progress: CGFloat
    var color : Color = .blue
    var padding : Float = 10
    var textColor : Color = .black
    var thick : Int = 5
    var text : () -> Content

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: CGFloat(thick))

            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [color]), center: .center),
                    style: StrokeStyle(lineWidth: CGFloat(thick), lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            text()
            
        }.padding(CGFloat(padding))
    }
}






