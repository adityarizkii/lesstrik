//
//  MyComponent.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 18/03/25.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: CGFloat // Nilai progress (0.0 - 1.0)
    var text : String
    var color : Color = .blue
    var padding : Float = 10

    var body: some View {
        ZStack {
            // Background Lingkaran (Track)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 5)

            // Progress Lingkaran (Indicator)
            Circle()
                .trim(from: 0.0, to: progress) // Trim sesuai progress
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [color]), center: .center),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Mulai dari atas

            // Teks di Tengah
            Text(text)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.black)
            
        }.padding(CGFloat(padding))
    }
}
