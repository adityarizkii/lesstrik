//
//  ContentView.swift
//  lesstrik
//
//  Created by Aditya Rizki on 15/03/25.
//

import SwiftUI
import SwiftData

struct BillDummy: Identifiable {
    let id = UUID()
    var date: Date
    var totalCost: Int
}

struct ContentView: View {
    // swiftdata
    @Environment(\.modelContext) private var context
    @EnvironmentObject var route : AppRoute
    @State var show = false
    @State var target = 0

//    @Query private var bills: [Bill]
    
    //dummy data
//    private var billsDummy: [BillDummy] = [
//        BillDummy(date: Date.now, totalCost: 55000),
//        BillDummy(date: Date.now.addingTimeInterval(-86400), totalCost: 40000)
//    ]
    
    // navigation
    @State private var path = NavigationPath()
    
    @State private var date: Date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack{
                VStack {
                    Text("Good Morning")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.largeTitle, weight: .bold))
                    
                    HStack {
                        Text("Rp10.000")
                            .font(.system(.title3))
                        Text("/")
                            .font(.system(.title3))
                        Text("Rp\(target)")
                            .font(.system(.title3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.blue), lineWidth: 2)
                            .fill(.blue.opacity(0.1))
                    )
                    
                    HStack {
                        Spacer()
                        Button (action : {
                            print("Set")
                            show = true
                        }){
                            Text("Set Your Goal")
                                .font(.system(.callout))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical,8)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.blue, lineWidth: 2)
                                .fill(.blue.opacity(0.3))
                        )
                    }

                    Text("Daily Usage")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.title, weight: .semibold))
                    
                    HStack {
                        Text("March 2025")
                        Spacer()
                        HStack {
                            Image(systemName: "chevron.left")
                            Image(systemName: "chevron.right")
                        }
                    }
                    
                    // calendar
                    HStack {
                        ForEach(daysOfWeek.indices, id:  \.self) { index in
                            Text(daysOfWeek[index])
                                .fontWeight(.black)
                                .foregroundStyle(.blue.opacity(0.8))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            if(day.monthInt != date.monthInt) {
                                Text("")
                            } else {
                                VStack(spacing: 0) {
                                    Text(day.formatted(.dateTime.day()))
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .foregroundStyle(date.startOfDay == day.startOfDay ? .blue : .gray)
    //                                if let bill = bills.first(where: { Calendar.current.isDate($0.date, inSameDayAs: day) }) {
    //                                    Text(formatToK(bill.totalCost))
    //                                        .font(.system(.caption2, weight: .medium))
    //                                        .frame(maxWidth: .infinity)
    //                                        .padding(.vertical, 4)
    //                                        .overlay(
    //                                            RoundedRectangle(cornerRadius: 4)
    //                                                .fill(.blue.opacity(0.3))
    //                                        )
    //                                } else {
    //                                    Text("-")
    //                                }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        path.append("Calculate")
                        route.currentPage = .dailyUsage
                    } label: {
                        Text("Hitung")
                            .foregroundStyle(.black)
                            .font(.system(.title3, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.blue.opacity(0.5))
                }
                .onAppear {
                    days = date.calendarDisplayDays
                    print(getDaysInMonth(from: convertToGMT7(date)))
                }
                .onChange(of: date) {
                    days = date.calendarDisplayDays
                    print(getDaysInMonth(from: convertToGMT7(date)))
                }
                .padding()
                
                .navigationDestination(for: String.self) { destination in
                    if destination == "Calculate" {
    //                    CalculationViewBeta()
                    }
                }
                
                
                myAlert(
                    visible : $show,
                    onSave : { value in
                        if var num = Int(value) {
                            target = num
                        }
                    },
                    onCancel: {
                        
                    }
                )
                
            }
           
            
        }
        
    }
    
    
    func formatToK(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000.0)
        }
        return "\(number)"
    }
    
    func formatTimeToGMT7(_ time: Date) -> String {
        // Buat formatter untuk menampilkan hasil
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Jakarta") // GMT+7

        // Konversi Date ke String dalam GMT+8
        let gmt7Time = formatter.string(from: time)
        return gmt7Time
    }
    
    func convertToGMT7(_ date: Date) -> Date {
        let timeZoneOffset = 7 * 3600 // 7 jam dalam detik
        return date.addingTimeInterval(TimeInterval(timeZoneOffset))
    }
    
    func getDaysInMonth(from date: Date) -> Int {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count ?? 0
    }
}

#Preview {
    @Previewable @StateObject var route = AppRoute()

    ContentView(
    )
        .environmentObject(route)
}
