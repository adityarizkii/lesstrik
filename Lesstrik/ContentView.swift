//
//  ContentView.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 17/03/25.

//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var isExpanded = false
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    let calendarData = [
        ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    ]
    
    func toggleExpanded() {
        isExpanded.toggle()
    }
    

    func getWeekdayIndex(year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = calendar.date(from: components) {
            let weekday = calendar.component(.weekday, from: date)
            return (weekday + 5) % 7
        }
        return -1
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            
            //Greeting text ke user
            Text("Good Morning!")
                .font(.system(size: 34, weight: .bold))
                .multilineTextAlignment(.leading)
                .padding(.vertical,20)
            
            //Data penggunaan dan goal
            HStack{
                Text("Rp.-,00")
                    .font(.system(size: 30, weight: .bold))
                Text("/")
                    .font(.system(size: 20, weight: .bold))
                Text("Rp.-,00")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 50)
            }
            .frame(minWidth: 0, maxWidth : .infinity, minHeight: 0)
            .background(RoundedRectangle(cornerRadius: 20).fill(Color(red : 0.8, green: 0.85 ,blue: 0.9)))
            
            //Button to set goal
            HStack(){
                Button(action : toggleExpanded)
                {
                    Text("Set Goal")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(10)
                        .frame(minWidth: 0,  minHeight: 0)
                }.background(RoundedRectangle(cornerRadius: 20).fill(Color(red : 0.8, green: 0.85 ,blue: 0.9)))
            }.frame(minWidth: 0, maxWidth : .infinity, minHeight: 0, alignment: .trailing)
            
            
            
            Text("Daily Usage")
                .font(.system(size: 24, weight: .bold))
            
            //Infomasi calendar
            HStack{
                Text("March 2025")
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                HStack{
                    Button(action : {
                        return
                    }){
                        Image(systemName : "chevron.left")
                    }
                    
                    Button(action : {
                        return
                    }){
                        Image(systemName: "chevron.right")
                    }
                }
            }.padding(.top, 0)
                .frame(minWidth : 0, maxWidth : .infinity, minHeight : 0, alignment: .topTrailing)
            
            //Calendar
            LazyVGrid(columns: rows){
                ForEach(0...6, id: \.self){ value in
                    if value == 0 {
                        Text(calendarData[value][0])
                            .font(.system(size: 14, weight: .bold))
                            .padding(.vertical, 5)
                        Text(calendarData[value][1])
                            .font(.system(size: 14, weight: .bold))
                        Text(calendarData[value][2])
                            .font(.system(size: 14, weight: .bold))
                        Text(calendarData[value][3])
                            .font(.system(size: 14, weight: .bold))
                        Text(calendarData[value][4])
                            .font(.system(size: 14, weight: .bold))
                        Text(calendarData[value][5])
                            .font(.system(size: 14, weight: .bold))
                        Text(calendarData[value][6])
                            .font(.system(size: 14, weight: .bold))
                    }else{
                        let firstDay = getWeekdayIndex(year: 2025, month: 3)

                        ForEach(1...7, id : \.self){ date in
                            let currentDate = 7 * (value - 1) + date
                            if currentDate > firstDay && currentDate - firstDay < 31{
                                CircularProgressView(
                                    progress: 0.7,
                                    text : "\(currentDate - firstDay)",
                                    color : Color.gray
                                )
                                
                            }else{
                                Spacer()
                            }
                           
                        }
                        
                       
                    }
                    
                }
            }
            
            Spacer()
            VStack {
                
                Button(action: {
                    print("Add Event Tapped")
                }) {
                    Text("Add Daily Usage")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 50).fill(.gray))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                
            }
       
        }
        .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment:.topLeading)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ContentView()
}
