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
    var textColor : Color = .black

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
                .foregroundColor(textColor)
            
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


struct myAlert : View{
    @State var visible : Bool = false
    @State var value : String = ""
    var onSave : (String) -> Void
    
    var body : some View{
        if visible {
            VStack{
                Text("SET YOUR GOAL")
                    .font(.headline)
                    .padding(.horizontal,20)
                    .padding(.top, 20)
                
                Text("Please input your usage target for this month")
                    .padding(.horizontal,20)
                    .multilineTextAlignment(.center)
                
                TextField("Input your goal", text : $value)
                    .padding(.horizontal,10)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius : 10)
                            .fill(Color.white)
                    )
                    .padding(.horizontal,20)
                
                
                HStack(spacing:0){
                    Button(action : {
                        visible = false
                    }){
                        Text("Cancel")
                            .frame(maxWidth : .infinity, alignment : .center)
                            .padding(10)
                    }
                    .background(
                        CustomRoundedRectangle(
                            topLeft : 0,
                            topRight: 0,
                            bottomLeft: 10,
                            bottomRight: 0
                        )
                        .stroke()
                        .fill(Color.gray.opacity(0.3))
                    )
                    .frame(maxWidth : .infinity, alignment : .center)
                    
                    Button(action : {
                        onSave(value)
                    }){
                        Text("Save")
                            .frame(maxWidth : .infinity, alignment : .center)
                            .padding(10)
                    }
                    .background(
                        CustomRoundedRectangle(
                            topLeft : 0,
                            topRight: 0,
                            bottomLeft:0,
                            bottomRight: 10
                        )
                        .stroke()
                        .fill(Color.gray.opacity(0.3))
                        
                    )
                    .frame(maxWidth : .infinity, alignment : .center)
                }
                .padding(.top, 20)
            }
            .background(
                RoundedRectangle(cornerRadius :10)
                    .fill(Color.gray)
            )
            .padding(50)
        }else{
            EmptyView()
                .frame(maxWidth : 0, maxHeight : 0)
        }
    }
}

#Preview{
    myAlert(
        visible : true,
        onSave : { value in
        return
    })
}
