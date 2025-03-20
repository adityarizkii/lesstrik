//
//  HomePage.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 20/03/25.
//
import SwiftUI

struct HomePage: View {
    @EnvironmentObject var route: AppRoute
    @State private var offset = CGSize.zero

    var body: some View {
        ZStack{
            VStack{
                Text("Hello, World!")
                Button(action : {
                    route.currentPage = .dailyUsage
                }){
                    Text("Go to Daily Usage")
                }
            }
            switch route.currentPage {
                case .dailyUsage:
                    DailyUsageView()
                default:
                    EmptyView()
            }
           
        }.gesture(
            DragGesture()
                .onChanged { gesture in
                    print(gesture.translation)
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        print("Ouchhh")
                    } else {
                        offset = .zero
                    }
                }
        )
        
    }
}

#Preview {
    @Previewable @StateObject var route = AppRoute()

    HomePage()
        .environmentObject(route)
       
}
