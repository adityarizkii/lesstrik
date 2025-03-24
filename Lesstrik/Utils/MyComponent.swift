//
//  MyComponent.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 18/03/25.
//

import SwiftUI

struct CircularProgressView<Content : View>: View {
    var progress: CGFloat // Nilai progress (0.0 - 1.0)
    var color : Color = .blue
    var padding : Float = 10
    var textColor : Color = .black
    var thick : Int = 5
    var text : () -> Content

    var body: some View {
        ZStack {
            // Background Lingkaran (Track)
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: CGFloat(thick))

            // Progress Lingkaran (Indicator)
            Circle()
                .trim(from: 0.0, to: progress) // Trim sesuai progress
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [color]), center: .center),
                    style: StrokeStyle(lineWidth: CGFloat(thick), lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Mulai dari atas

            // Teks di Tengah
            text()
            
        }.padding(CGFloat(padding))
    }
}


struct CustomRoundedRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + topRight),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - bottomLeft),
                          control: CGPoint(x: rect.minX, y: rect.maxY))
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
        path.addQuadCurve(to: CGPoint(x: rect.minX + topLeft, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}


struct myAlert: View {
    @Binding var visible: Bool
    @State var value: String = ""
    var onSave: (String) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        if visible {
            VStack {
                Text("SET YOUR GOAL")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                Text("Please input your usage target for this month")
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)

                TextField("Input your goal", text: $value)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                    )
                    .padding(.horizontal, 20)

                HStack(spacing: 0) {
                    Button(action: {
                        visible = false  // ✅ Tutup alert
                        onCancel()
                    }) {
                        Text("Cancel")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                    }
                    .background(
                        CustomRoundedRectangle(
                            topLeft: 0, topRight: 0, bottomLeft: 10, bottomRight: 0
                        )
                        .stroke()
                        .fill(Color.gray.opacity(0.3))
                    )
                    .frame(maxWidth: .infinity, alignment: .center)

                    Button(action: {
                        visible = false  // ✅ Tutup alert
                        onSave(value)
                    }) {
                        Text("Save")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(10)
                    }
                    .background(
                        CustomRoundedRectangle(
                            topLeft: 0, topRight: 0, bottomLeft: 0, bottomRight: 10
                        )
                        .stroke()
                        .fill(Color.gray.opacity(0.3))
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.top, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("LightGrey"))
            )
            .padding(50)
        } else {
            EmptyView()
                .frame(maxWidth: 0, maxHeight: 0)
        }
    }
}


struct WaterProgressView <Content : View>: View  {
    var progress: Double = 0.5
    @State var waveOffset: CGFloat = 0.0
    @State var val : Double = 2
    var content : () -> Content
    
    var body: some View {
        VStack {
            ZStack {
                WaterShape(progress: progress, waveOffset: waveOffset)
                    .fill(Color.green.opacity(0.6))
                    .frame(width: 150, height: 150)
                    .overlay(
                        content()
                    )
                    .clipShape(Circle())
                    .onAppear {
                       
                        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                            waveOffset = .pi * val * 0.3
                            val += 0.1
                        }
                       
                    }
                    .background(
                        Circle()
                            .fill(Color.green.opacity(0.1))
                    )
            }
        }
    }
}

struct WaterShape: Shape {
    var progress: Double
    var waveOffset: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let waterHeight = rect.height * (1 - CGFloat(progress))
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
