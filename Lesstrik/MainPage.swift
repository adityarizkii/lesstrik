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
    @State var usageData : DailyUsageModel =
        DailyUsageModel(
            id : UUID(),
            date : Date.now,
            totalCost : 0
        )
    
    var body: some View {
        
        ZStack{

            switch route.currentPage {
                
                case .dailyUsage:
                DailyUsageView(usageData : $usageData)
                default:
                HomePage(usageData : $usageData)
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
