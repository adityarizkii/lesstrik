//
//  ButtomRounded.swift
//  Lesstrik
//
//  Created by Aditya Rizki on 25/03/25.
//

import SwiftUI

struct BottomRoundedShape: Shape {
    var radius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.bottomLeft, .bottomRight], // Hanya sudut bawah kiri & kanan
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
