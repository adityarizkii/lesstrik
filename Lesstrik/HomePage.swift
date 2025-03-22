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

            switch route.currentPage {
                
                case .dailyUsage:
                    DailyUsageView()
                default:
                ContentView()
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
   
    HomePage()
        .environmentObject(AppRoute())
       
}
