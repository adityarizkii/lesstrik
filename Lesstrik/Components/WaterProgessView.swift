//
//  WaterProgessView.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 26/03/25.
//

import SwiftUI

struct WaterProgressView<Content: View>: View {
    @State private var timer: DispatchSourceTimer?
    private let queue = DispatchQueue(label: "com.example.background", qos: .background)

    var progress: Double = 0.5
    @State private var waveOffset: CGFloat = 0.0
    @State private var val: Double = 2
    var content: () -> Content
    var color: Color = .green.opacity(0.6)

    var body: some View {
        VStack {
            ZStack {
                WaterShape(progress: progress, waveOffset: waveOffset)
                    .fill(color)
                    .frame(width: 150, height: 150)
                    .overlay(content())
                    .clipShape(Circle())
                    .onAppear {
                        startTimer()
                    }
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.1))
                    )
                    .onDisappear {
                        stopTimer()
                    }
            }
        }
    }

    private func startTimer() {
        stopTimer()
        
        let newTimer = DispatchSource.makeTimerSource(queue: queue)
        newTimer.schedule(deadline: .now(), repeating: 0.001)

        newTimer.setEventHandler {
            DispatchQueue.main.async {
                waveOffset = .pi * val
                val += 0.02
            }
        }

        newTimer.resume()
        timer = newTimer
    }

    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
}


struct WaterShape: Shape {
    var progress: Double
    var waveOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        var waterHeight = rect.height * (1 - CGFloat(progress))
        let waveAmplitude: CGFloat = 10
        let waveLength: CGFloat = rect.width / 1.2
        
        path.move(to: CGPoint(x: 0, y: waterHeight))
        for x in stride(from: 0, through: rect.width, by: 1) {
            let relativeX = x / waveLength
            let sine = sin(relativeX * .pi * 2 + waveOffset)
 
            let y = waterHeight + sine * waveAmplitude
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        
        path.closeSubpath()
        
        return path
    }
}


#Preview{
    WaterProgressView(){
        Text("Hallo")
    }
}
