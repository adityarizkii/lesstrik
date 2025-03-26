//
//  Calendar.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 26/03/25.
//
import SwiftUI

struct MyCalendar{
    @Binding var currentMonth : Int
    @Binding var currentYear : Int
    var prevMonth : (() -> Void) = {}
    var nextMonth : (() -> Void) = {}
    let daysOfWeek : [String] = Date.capitalizedFirstLettersOfWeekdays
    var year = 2025
    var date : Date = Date()
    var days : [Date] = []
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State var costData : [Double] = Array(repeating : 0.0, count : 33)
    var onTap : ((Date) -> Void) = {_ in }
    @Binding var route:AppRoute
    
    var body : some View{
        VStack{
            Text("Daily Usage")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(.title3, weight: .medium))
                .padding(.bottom, 6)
            HStack {
                Text("\(getMonthString(m: currentMonth)) \(String(currentYear))")
                Spacer()
                HStack(spacing : 30) {
                    Image(systemName: "chevron.left")
                        .onTapGesture {
                            withAnimation{
                                prevMonth()
                            }
                           
                            
                        }
                    Image(systemName: "chevron.right")
                        .onTapGesture {
                            withAnimation{
                               nextMonth()
                            }
                        }
                }
            }
            
            // calendar
            HStack {
                ForEach(daysOfWeek.indices, id:  \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.black)
                        .foregroundStyle(Color("TextDefault"))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top)
            .padding(.horizontal,0)
            
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(days, id: \.self) { day in
                    if(day.monthInt != date.monthInt) {
                        Text("")
                    } else {
                        VStack(spacing: 0) {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, minHeight: 35)
                                .foregroundStyle(date.startOfDay == day.startOfDay && currentMonth == Date().monthInt - 1 ? Color("Green") : Color("TextDefault"))
                            
                            if ( date.startOfDay >= day.startOfDay && currentMonth + 1 == Date().monthInt  )
                                ||
                                (
                                    currentMonth < Date().monthInt - 1  )
                                ||
                                (
                                    currentYear < year   )
                                
                            {
                                Text(
                                    ( String(
                                        format : "%.f",
                                        costData[Int(day.formatted(.dateTime.day())) ?? 0]
                                    )) + "k"
                                )
                                .font(.caption2)
                                .foregroundStyle(Color("TextDefault"))
                                .bold(true)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(
                                    RoundedRectangle(cornerRadius : 3)
                                        .stroke(
                                            Color("Yellow"),
                                            style : StrokeStyle(
                                                lineWidth : 2
                                            )
                                        )
                                        .fill(.yellow.opacity(0.1))
                                )
                                .offset(y :  -3)
                                .frame(maxWidth : .infinity)
                            }else{
                                Text("          ")
                                    .font(.caption2)
                                    .bold(true)
                                    .padding(.horizontal, 5)
                                    .offset(y :  -8)
                            }
                            
                        }
                        .padding(.vertical, 5)
                        .frame(maxWidth : .infinity)
                        .onTapGesture{
                            onTap(day)
                        }
                    }
                }
            }
            .padding(.horizontal,0)
            .transition(.opacity)
            .animation(.easeInOut, value : currentMonth)
            
        }
    }
}
