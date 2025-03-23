//
//  HomePage.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 20/03/25.
//
import SwiftUI

struct MainPage: View {
    @EnvironmentObject var route: AppRoute
    @State private var offset = CGSize.zero
    @State var usageID : UUID = UUID()
    
    var body: some View {
        
        ZStack{

            switch route.currentPage {
                
                case .dailyUsage:
                DailyUsageView(usageID : $usageID)
                default:
                HomePage(usageID : $usageID)
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
    @Previewable @State var route = AppRoute()

    MainPage()
        .environmentObject(route)
       
}
