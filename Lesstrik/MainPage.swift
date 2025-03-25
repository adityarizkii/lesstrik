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
    @State var currentMonth = Date().monthInt-1
    @State var currentYear = 2025
    @State var year = 2020
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
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                            }
                            .onEnded { _ in
                                
                                print(offset.width)
                                if offset.width > 100 {
                                    route.currentPage = .home
                                } else {
                                    offset = .zero
                                }
                            }
                    )
                default:
                HomePage(
                    usageData : $usageData,
                    currentMonth : $currentMonth,
                    currentYear : $currentYear,
                    year : $year
                )
            }
            
            HStack{
                Text("")
                    .frame(maxWidth  : .infinity, alignment: .top)
                    .padding(0)
            }
            .padding(0)
            .ignoresSafeArea(.all)
            .background(.ultraThinMaterial)
            .frame(maxWidth : .infinity, maxHeight : .infinity, alignment: .top)
            .offset(y :-20)
           
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
        

        
    }
        
}

#Preview {
    @Previewable @State var route = AppRoute()

    MainPage()
        .environmentObject(route)
       
}
