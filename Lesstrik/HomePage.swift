//
//  ContentView.swift
//  lesstrik
//
//  Created by Aditya Rizki on 15/03/25.
//

import SwiftUI
import SwiftData
import Foundation

struct BillDummy: Identifiable {
    let id = UUID()
    var date: Date
    var totalCost: Int
}


func getCurrentDateAtMidnight(date : Date = Date()) -> Date? {
    let calendar = Calendar.current

    // Mengambil komponen tanggal (tahun, bulan, hari)
    let components = calendar.dateComponents([.year, .month, .day], from: date)

    // Membuat Date dengan jam 00:00:00
    return calendar.date(from: components)
}


struct HomePage: View {
    // swiftdata
    @Environment(\.modelContext) private var context
    @EnvironmentObject var route : AppRoute
    @State var show = false
    @State var usage = 200000
    @State var currentMonth = Date().monthInt
    var dailyUsage = DailyUsage()
    var daily:DailyUsageModel = DailyUsageModel(
        id: UUID(), date: Date.now, totalCost: 0
    )
    var formater = DateFormatter()
    @State var currentPeriod:String = ""
    @State var record = Record()
    @Binding var usageID: UUID
    @State var recordData : RecordType = RecordType(
        id : UUID(),
        period : "",
        usage_goal : Int32(0)
    )


    
    func fetchDailyUsage(date : Date?, callback : @escaping (() -> Void)){
        if date != nil {
            
            self.dailyUsage.getDailyUsagesByDate(date: date ?? Date.now) { result in
                if result != nil {
                    daily.id = result!.id
                    daily.date = result!.date
                    daily.totalCost = result!.totalCost
                    usageID = result!.id
                    callback()
                    print("Daily : Berhasil mengambil data !")
                    return
                }
                
                self.dailyUsage.create(
                    data:
                        DailyUsageModel(
                            id : UUID(),
                            date : date ?? Date.now,
                            totalCost : 0
                        )
                ) { error, message in
                    if !error {
                        self.dailyUsage.getDailyUsagesByDate(date: date ?? Date.now) { result in
                            
                            if result != nil {
                                daily.id = result!.id
                                daily.date = result!.date
                                daily.totalCost = result!.totalCost
                                usageID = result!.id
                                callback()

                                return
                            }
                        }
                    }
                    
                    print("Daily : \(String(describing: error)), \(String(describing: message))")
                }
            }
        }
        
    }
    
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
                        .padding(.top, 20)
                    HStack{
                        
                        ZStack{
                            CircularProgressView(
                                progress : Double(usage)/Double(recordData.usage_goal ),
                                color : Color("TintedGreen"),
                                padding : 1,
                                thick : 20
                            ){
                                VStack{
                                    Text("Rp")
                                        .font(.title2)
                                        .bold(true)
                                    Text("\(usage)")
                                        .font(.subheadline)
                                        .bold(true)
                                        .foregroundStyle(Color("TintedGreen"))
                                    Text("\(recordData.usage_goal  )")
                                        .font(.caption)
                                }
                              
                            }
                            .padding(.vertical,20)
                            .padding(.leading, 10)
                            .frame(maxHeight : 150)
                            
                             
                            Button (action : {
                                print("Set")
                                show = true
                            }){
                                Text("Set Goal")
                                    .font(.system(.caption))
                                    .foregroundStyle(.black)
                                    .bold(true)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical,8)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .fill(Color("Yellow"))
                            )
                            .frame(alignment : .bottom)
                            .offset(y:50)
                            .padding(.leading, 10)

                        }
                        .frame(alignment : .bottom)
                        
                        Spacer()
                        
                        VStack{
                            Text("Daily Goal : ")
                                .font(.headline)
                                .frame(maxWidth : .infinity, alignment : .leading)
                            Text("Rp \( Int32(recordData.usage_goal)  / Int32(30))")
                                .frame(maxWidth : .infinity, alignment : .leading)
                                .padding(.bottom, 2)
                                .font(.title2)
                                .bold(true)
                            
                            Text("Avg. Usage :")
                                .font(.headline)
                                .frame(maxWidth : .infinity, alignment : .leading)
                            Text("Rp \( Int32(recordData.usage_goal)  / Int32(30))")
                                .frame(maxWidth : .infinity, alignment : .leading)
                                .font(.title2)
                                .bold(true)
                            
                        }
                        .frame(maxWidth : .infinity, alignment : .top)
                        .padding(.leading , 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.blue), lineWidth: 2)
                            .fill(.gray.opacity(0.1))
                    )
                    
                    HStack {
                        Spacer()
                        
                    }

                    Text("Daily Usage")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(.title, weight: .bold))
                        .padding(.top, 20)
                    
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
                                .foregroundStyle(Color("ShadedGreen"))
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
                                        .frame(maxWidth: .infinity, minHeight: 40)
                                        .foregroundStyle(date.startOfDay == day.startOfDay ? .blue : Color("DarkYellow"))
                                    
                                    if date.startOfDay >= day.startOfDay {
                                        Text("10k")
                                            .font(.caption2)
                                            .foregroundStyle(Color("Green"))
                                            .bold(true)
                                            .padding(.horizontal, 5)
                                            .background(
                                                RoundedRectangle(cornerRadius : 5).fill(Color("Yellow"))
                                            )
                                            .offset(y :  -8)
                                    }

                                }
                                .onTapGesture{
                                    fetchDailyUsage(date: getCurrentDateAtMidnight(date: addDays(to: day, days: 1))){
                                        print(addDays(to: day, days: 1))
                                        print(usageID)
                                        route.currentPage = .dailyUsage
                                    }
                                   
                                }
                            }
                        }
                    }
                    .padding(.horizontal,0)
                    
                    Spacer()
                    
                    Button {
                        //path.append("Calculate")
                        route.currentPage = .dailyUsage
                    } label: {
                        Text("Add Daily Usage")
                            .foregroundStyle(Color("ShadedGreen"))
                            .font(.system(.title3, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(
                            cornerRadius : 50
                        )
                        .fill(Color("Yellow"))
                    )
                }
               
                .onChange(of: date) {
                    days = date.calendarDisplayDays
                    print(getDaysInMonth(from: convertToGMT7(date)))
                }
                .padding(.horizontal, 25)
                
                .navigationDestination(for: String.self) { destination in
                    if destination == "Calculate" {
    //                    CalculationViewBeta()
                    }
                }
                
                
                myAlert(
                    visible : $show,
                    onSave : { value in
                        if let num = Int(value) {
                            self.record.addRecord(data: RecordType(
                                id : recordData.id,
                                period : self.currentPeriod,
                                usage_goal : Int32(num)
                            ))
                            record.getRecords(period: self.currentPeriod){ value in
                                if value != nil {
                                    recordData = value!
                                }
                                
                            }
                        }
                    },
                    onCancel: {
                        
                    }
                )
                
            }
            .onAppear {
                self.formater.setLocalizedDateFormatFromTemplate( "yyyyMM" )
                self.currentPeriod = self.formater.string(from : Date.now)
                self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
                days = date.calendarDisplayDays
                record.getRecords(period : self.currentPeriod){ value in
                    if value != nil {
                        recordData = value!
                        usageID = value!.id
                    }
                }
                
                fetchDailyUsage(date : getCurrentDateAtMidnight()){
                    
                }
                
                print("Sekarang : \(String(describing: self.recordData.usage_goal))")

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

    HomePage(
        usageID : .constant(UUID()))
        .environmentObject(route)
}
