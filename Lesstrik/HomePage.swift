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
    @Binding var usageData: DailyUsageModel

    @Environment(\.modelContext) private var context
    @EnvironmentObject var route : AppRoute
    @State var show = false
    @State var usage = 0
    @State var averageUsage = 0
    @Binding var currentMonth:Int
    var dailyUsage = DailyUsage()
    var daily:DailyUsageModel = DailyUsageModel(
        id: UUID(), date: Date.now, totalCost: 0
    )
    var dailyUsageData = [DailyUsageModel]()
    var formater = DateFormatter()
    var yearFormatter = DateFormatter()
    @Binding var currentYear:Int
    @Binding var year:Int
    @State var currentPeriod:String = ""
    @State var record = Record()
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
    
    func fetchUsages(){
        usage = 0
        averageUsage = 0
        dailyUsage.fetchDailyUsagesByMonth(
            year : currentYear, month : self.currentMonth + 1
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
    }
    
    func fetchRecord(){
        self.currentPeriod = self.formater.string(from : Date.now)
        self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
        var date = DateComponents()
        date.day = Calendar.current.component(.day, from : Date.now)
        date.month = self.currentMonth + 1
        date.year = self.currentYear
        if let d = Calendar.current.date(from: date){
            days = d.calendarDisplayDays
            self.date = d
            self.formater.dateFormat = "MMyyyy"
            self.currentPeriod = self.formater.string(from : d)
            self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
            print("Tanggal skrg : \(d)   -  \(self.currentPeriod)")

            record.getRecords(period: self.currentPeriod){ value in
                if value != nil {
                    recordData = value!
                }else{
                    print("Nothing")
                    recordData = RecordType(
                        id : UUID(),
                        period : self.currentPeriod,
                        usage_goal:  0
                    )
                }
                
            }
        }
        
        fetchDailyUsage(date : getCurrentDateAtMidnight()){
            
        }
        record.getRecords(period : self.currentPeriod){ value in
            if value != nil {
                recordData = value!
                usageData.id = value!.id
            }
        }
        
    }
    
    func getFinalCost()->Int{
        return Int(Double(usage + 66704) * 1.08)
    }
    
    func Greetings() -> String {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: Date())
        if hour >= 3 && hour < 12 {
            return "Good Morning"
        } else if hour >= 12 && hour < 16 {
            return "Good Afternoon"
        } else {
            return "Good Evening"
        }
    }
    
    func getProgress() -> Double{
        if recordData.usage_goal == 0{
            return 0
        }
        return Double(getFinalCost())/Double(recordData.usage_goal )
    }
    
    func getColor()->Color{
        if getProgress() < 0.5{
            return .green.opacity(0.6)
        }else if getProgress() < 0.9{
            return Color("Warning")
        }
        
        return Color("Danger")
    }
    
    func getProgerssTextColor()->Color{
        if getProgress() < 0.5{
            return Color("TintedGreen")
        }else if getProgress() < 0.9{
            return Color.orange
        }
        
        return Color.red
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
                VStack{
                    ScrollView{
                        VStack(spacing : 0) {
                            
                            HStack{
                                Image("AppLogo")
                                    .resizable()
                                    .scaledToFit( )
                                    .frame(width: 30, height: 50)
                                    .clipShape(Circle())
                                
                                Text("Lesstrik")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(.title, weight: .bold))
                            }
                            .padding(.bottom)
                            .frame(alignment : .center)
                            VStack{
                                ZStack{
                                    WaterProgressView(
                                        progress : getProgress(),
                                        color : getColor()
                                    ){
                                        Text("\(String(format  : "%.0f" , getProgress() * 100.0) + "%")")
                                           .font(.title)
                                           .foregroundStyle(getProgerssTextColor())
                                           .bold(true)
                                    }
    //                                CircularProgressView(
    //                                    progress : getProgress(),
    //                                    color : Color("TintedGreen"),
    //                                    padding : 1,
    //                                    thick : 25
    //                                ){
    //                                    VStack{
    //                                        Text("\(String(format  : "%.0f" , getProgress() * 100.0) + "%")")
    //                                            .font(.title)
    //                                            .foregroundStyle(Color("TintedGreen"))
    //                                            .bold(true)
    //                                        Text("From target")
    //                                            .font(.caption2)
    //                                            .bold(true)
    //                                            .foregroundStyle(Color("TintedGreen"))
    //
    //                                    }
    //
    //                                }
    //                                .padding(.leading, 10)
    //                                .padding(.top, 20)
    //                                .frame(height : 140)
                                    
                                }
                                .frame(maxHeight : .infinity, alignment : .center)
                                .padding(.bottom, 10)
                                VStack(spacing : 16){
                                    HStack{
                                                                                
                                        VStack(spacing : 5){
                                            Text("Monthly Usage")
                                                .font(.subheadline)
                                                .bold(true)
                                                .multilineTextAlignment(.trailing)
                                                .frame(maxWidth : .infinity, alignment : .leading)
                                            
                                            HStack(spacing : 0){
                                                Text("Rp \( Int32(getFinalCost()))")
                                                    .foregroundStyle(
                                                        getProgerssTextColor()
                                                    )
                                                    .font(.title2)
                                                    .bold(true)
                                                    .frame(alignment : .leading)
                                                    .padding(.trailing, 3)
//                                                Image(systemName: "info.circle")
//                                                    .frame(alignment : .leading)
//                                                    .offset(y : -25)
                                            }
                                            .frame(maxWidth : .infinity, alignment : .leading)
                                           
                                        }
                                        .frame(
                                            maxWidth : .infinity,
                                            alignment : .topTrailing
                                        )
                                        
                                        
                                        Spacer()
                                        
                                        VStack(spacing : 5){
                                            Text("Monthly Limit")
                                                .font(.subheadline)
                                                .bold(true)
                                                .frame(maxWidth : .infinity, alignment : .trailing)
                                            Text("Rp \( Int32(recordData.usage_goal) )")
                                                .frame(maxWidth : .infinity, alignment : .trailing)
                                                .padding(.bottom, 2)
                                                .font(.title2)
                                                .bold(true)
                                            
                                            
                                            
                                        }
                                        .frame(
                                            maxWidth : .infinity,
                                            alignment : .topLeading
                                        )
                                        
                                        
                                    }
                                    .frame(maxWidth : .infinity, alignment : .top)
                                    .padding(.horizontal , 10)
                                    
                                    HStack{
                                        VStack{
                                            Text("Daily Average : ")
                                                .font(.caption)
                                                .bold(true)
                                                .frame(maxWidth : .infinity, alignment : .leading)
                                            Text("Rp \( Int32(getFinalCost()/30))")
                                                .font(.subheadline)
                                                .bold(true)
                                                .frame(maxWidth : .infinity, alignment : .leading)
                                        }
                                        .frame(alignment : .topTrailing)
                                        
                                        Spacer()
                                        
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
                                        
                                        
                                    }
                                    .padding(.horizontal, 10)
                                }
                                .padding(.top)
                            }
                            .frame(
                                maxWidth: .infinity,
                                alignment : .top
                            )
                            .padding(.vertical, 20)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(.blue), lineWidth: 2)
                                    .fill(.gray.opacity(0.05))
                            )
                            
                            HStack {
                                Spacer()
                                
                            }
                            
                            VStack{
                                Text("Daily Usage")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(.title3, weight: .medium))
                                    .padding(.bottom, 6)
                                HStack {
                                    Text("\(getMonthString(m: currentMonth)) \(String(currentYear))")
                                    Spacer()
                                    HStack {
                                        Image(systemName: "chevron.left")
                                            .onTapGesture {
                                                currentYear -= currentMonth == 0 ? 1 : 0
                                                currentMonth = (currentMonth + 11) % 12
                                                fetchRecord()
                                                fetchUsages()
                                                fetchDailyUsage(date: self.date){
                                                    
                                                }
                                                
                                            }
                                        Image(systemName: "chevron.right")
                                            .onTapGesture {
                                                currentYear += currentMonth == 11 ? 1 : 0
                                                currentMonth = (currentMonth + 13) % 12
                                                fetchRecord()
                                                fetchUsages()
                                                fetchDailyUsage(date: date){
                                                    
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
                                                fetchDailyUsage(date: getCurrentDateAtMidnight(date: addDays(to: day, days: 1))){
                                                    print(addDays(to: day, days: 1))
                                                  
                                                    route.currentPage = .dailyUsage
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal,0)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal)
                            .background(
                                RoundedRectangle(
                                    cornerRadius : 10
                                )
                                .stroke(Color(.blue), lineWidth: 2)
                                .fill(.gray.opacity(0.05))
                            )
                            .padding(.top, 20)
                            
                            
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
                    
                    
                    Spacer()
                    
                    Button {
                        //path.append("Calculate")
                        route.currentPage = .dailyUsage
                    } label: {
                        Text("Add Today Usage")
                            .foregroundStyle(.black)
                            .font(.system(.title3, weight: .bold))
                            .frame(maxWidth : .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(
                            cornerRadius : 50
                        )
                        .fill(Color("Yellow"))
                    )
                    .padding(.horizontal, 25)

                }
                
                
                myAlert(
                    visible : $show,
                    onSave : { value in
                        if let num = Int(value) {
                            var date = DateComponents()
                            date.day = Calendar.current.component(.day, from : self.date)
                            date.month = self.currentMonth + 1
                            date.year = self.currentYear
                            if let d = Calendar.current.date(from: date){
                                days = d.calendarDisplayDays
                                self.date = d
                                
                                self.currentPeriod = self.formater.string(from : d)
                                self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
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
                        }
                    },
                    onCancel: {
                        
                    }
                )
                
            }
            .onAppear {
                self.formater.setLocalizedDateFormatFromTemplate( "yyyyMM" )
                self.yearFormatter.setLocalizedDateFormatFromTemplate("yyyy")
                self.currentYear = Int(self.yearFormatter.string(from : Date.now))!
                self.year = Int(self.yearFormatter.string(from : Date.now))!
                self.currentPeriod = self.formater.string(from : Date.now)
                self.currentPeriod = self.currentPeriod.replacingOccurrences(of: "/", with: "")
                days = date.calendarDisplayDays
                
//                fetchDailyUsage(date : getCurrentDateAtMidnight()){ data in
//                    
//                }
                fetchRecord()
                fetchUsages()
                
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
    @Previewable @State var currentMonth = Date().monthInt-1
    @Previewable @State var currentYear = 2025
    @Previewable @State var year = 2020
    @Previewable @State var usageData : DailyUsageModel =
        DailyUsageModel(
            id : UUID(),
            date : Date.now,
            totalCost : 0
        )
    HomePage(
        usageData : $usageData,
        currentMonth : $currentMonth,
        currentYear : $currentYear,
        year : $year
    )

    .environmentObject(route)
}
