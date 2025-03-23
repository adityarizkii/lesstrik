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

func Greeting() -> String{
    let calender = Calendar.current
    let hour = calender.component(.hour, from: Date())
    if hour < 12{
        return "Good Morning"
    }else if hour < 16{
        return "Good Afternoon"
    }else {
        return "Good Evening"
    }
}


struct HomePage: View {
    // swiftdata
    @Environment(\.modelContext) private var context
    @EnvironmentObject var route : AppRoute
    @State var show = false
    @State var usage = 200000
    @State var averageUsage = 0
    @State var currentMonth = Date().monthInt
    var dailyUsage = DailyUsage()
    var daily:DailyUsageModel = DailyUsageModel(
        id: UUID(), date: Date.now, totalCost: 0
    )
    var dailyUsageData = [DailyUsageModel]()
    var formater = DateFormatter()
    var yearFormatter = DateFormatter()
    @State var currentPeriod:String = ""
    @State var record = Record()
    @Binding var usageData: DailyUsageModel
    @State var recordData : RecordType = RecordType(
        id : UUID(),
        period : "",
        usage_goal : Int32(0)
    )
    @State var costData : [Double] = Array(repeating : 0.0, count : 33)


    
    func fetchDailyUsage(date : Date?, callback : @escaping (() -> Void)){
        if date != nil {
            
            self.dailyUsage.getDailyUsagesByDate(date: date ?? Date.now) { result in
                if result != nil {
                    daily.id = result!.id
                    daily.date = result!.date
                    daily.totalCost = result!.totalCost
                    usageData = result!
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
                                usageData = result!
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
<<<<<<< HEAD
                VStack {
                    Text(Greeting())
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
                        
=======
                ScrollView{
                    VStack(spacing : 0) {
                        Text("Good Morning")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(.largeTitle, weight: .bold))
                            .padding(.top, 20)
                            .padding(.bottom , 20)
>>>>>>> 69617658d03161e69fa77a91dfbac78c0c25fb0d
                        VStack{
                            
                            ZStack{
                                CircularProgressView(
                                    progress : Double(usage)/Double(recordData.usage_goal ),
                                    color : Color("TintedGreen"),
                                    padding : 1,
                                    thick : 30
                                ){
                                    VStack{
                                        Text("\(String(format  : "%.0f" , Double(usage)/Double(recordData.usage_goal) * 100.0) + "%")")
                                            .font(.title)
                                            .bold(true)
                                    }
                                    
                                }
                                .padding(.leading, 10)
                                .padding(.top, 20)
                                .frame(height : 140)
                                
                            }
                            .frame(alignment : .center)
                            
                            VStack(spacing : 0){
                                HStack{
                                    VStack{
                                        Text("Goal")
                                            .font(.subheadline)
                                            .frame(maxWidth : .infinity, alignment : .leading)
                                        Text("Rp \( Int32(recordData.usage_goal) )")
                                            .frame(maxWidth : .infinity, alignment : .leading)
                                            .padding(.bottom, 2)
                                            .font(.title2)
                                            .bold(true)
                                        
                                        
                                        
                                    }
                                    .frame(
                                        maxWidth : .infinity,
                                        alignment : .topLeading
                                    )
                                    
                                    Spacer()
                                    
                                    VStack{
                                        Text("Monthly Usage")
                                            .font(.subheadline)
                                            .bold(true)
                                            .foregroundStyle(
                                                Color("ShadedGreen")
                                            )
                                            .multilineTextAlignment(.trailing)
                                            .frame(maxWidth : .infinity, alignment : .trailing)
                                        Text("Rp \( Int32(usage))")
                                            .foregroundStyle(
                                                Color("ShadedGreen")
                                            )
                                            .font(.title2)
                                            .bold(true)
                                            .frame(maxWidth : .infinity, alignment : .trailing)
                                    }
                                    .frame(
                                        maxWidth : .infinity,
                                        alignment : .topTrailing
                                    )
                                    
                                    
                                }
                                .frame(maxWidth : .infinity, alignment : .top)
                                .padding(.horizontal , 10)
                                
                                HStack{
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
                                        RoundedRectangle(cornerRadius: 5)
                                            .fill(Color("Yellow"))
                                    )
                                    
                                    Spacer()
                                    
                                    VStack{
                                        Text("Rp \( Int32(averageUsage))/Day")
                                            .font(.subheadline)
                                            .bold(true)
                                            .frame(maxWidth : .infinity, alignment : .trailing)
                                    }
                                    .frame(alignment : .topTrailing)
                                }
                                .padding(.horizontal, 10)
                            }.padding(.top, 10)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment : .top
                        )
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.blue), lineWidth: 2)
                                .fill(.gray.opacity(0.05))
                        )
                        
                        HStack {
                            Spacer()
                            
                        }
                        
                        Text("Daily Usage")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .bold(true)
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
                                            .frame(maxWidth: .infinity, minHeight: 35)
                                            .foregroundStyle(date.startOfDay == day.startOfDay ? .blue : Color("DarkYellow"))
                                        
                                        if date.startOfDay >= day.startOfDay {
                                            Text(
                                                ( String(
                                                    format : "%.1f",
                                                    costData[Int(day.formatted(.dateTime.day())) ?? 0]
                                                )) + "k"
                                            )
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
                                            print("idx :  \( costData[Int(day.formatted(.dateTime.day())) ?? 0])")
                                            route.currentPage = .dailyUsage
                                        }
                                        
                                    }
                                }
                            }
                        }
<<<<<<< HEAD
                    }
                    .padding(.horizontal,0)
                    
                    Spacer()
                    
                    Button {
                        //path.append("Calculate")
                        route.currentPage = .dailyUsage
                    } label: {
                        Text("Check in Today")
                            .foregroundStyle(Color("ShadedGreen"))
                            .font(.system(.title3, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(
                            cornerRadius : 50
=======
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
>>>>>>> 69617658d03161e69fa77a91dfbac78c0c25fb0d
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
                self.yearFormatter.setLocalizedDateFormatFromTemplate("yyyy")
                self.currentPeriod = self.formater.string(from : Date.now)
                self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
                days = date.calendarDisplayDays
                record.getRecords(period : self.currentPeriod){ value in
                    if value != nil {
                        recordData = value!
                        usageData.id = value!.id
                    }
                }
                
                fetchDailyUsage(date : getCurrentDateAtMidnight()){
                    
                }
                
                dailyUsage.fetchDailyUsagesByMonth(
                    year : Int(yearFormatter.string(from : Date.now)) ?? 0, month : self.currentMonth
                ){ result in
                    var arr = Array(repeating : 0.0, count : 33)
                    usage = 0
                    if result?.count ?? 0 > 0 {
                        let calendar = Calendar.current
                        result?.forEach { (item) in
                            
                            arr[calendar.component(.day, from : item.date)-1] = Double(item.totalCost)/1000
                            if item.totalCost > 0 {
                                averageUsage = (averageUsage  + Int(item.totalCost))/2
                            }
                            usage += Int(item.totalCost)
                            print("[\(calendar.component(.day, from : item.date))]Tgl : \(item.date)  \(item.totalCost)")
                        }
                    }
                    costData = arr

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
        usageData :
                .constant(
                    DailyUsageModel(
                        id : UUID(),
                        date : Date.now,
                        totalCost : 0
                    )
                )
    )
    .environmentObject(route)
}
