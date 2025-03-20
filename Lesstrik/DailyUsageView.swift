//
//  DailyUsageView.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 18/03/25.
//
import SwiftUI


class DeviceData: ObservableObject, Identifiable, Equatable {
    static func == (lhs: DeviceData, rhs: DeviceData) -> Bool {
           return lhs.id == rhs.id &&
                  lhs.name == rhs.name &&
                  lhs.power == rhs.power &&
                  lhs.time == rhs.time
       }

       var id: Int64
       @Published var name: String
       @Published var power: Int
       @Published var time: Float

       init(id: Int64, name: String, power: Int, time: Float) {
           self.id = id
           self.name = name
           self.power = power
           self.time = time
       }
}

struct DailyUsageView:View{
    @EnvironmentObject var route: AppRoute
    @State var offset = CGSize.zero
    @State var count : Int64 = 1
    @State var showDetail = false
    @StateObject var DailyData = Daily()

    
    let templateRow = [
        GridItem(.fixed(30)),
        GridItem(.flexible()),
        GridItem(.fixed(50)),
        GridItem(.fixed(50)),
        GridItem(.fixed(30)),

    ]
    
    let columns = ["No", "Name" , "Power", "Time", ""];
    @State var data : [DeviceData] = [
        DeviceData(id : 0, name : "" , power : 0, time : 0.0)
    ];
    
    
    @State var totalCost: Int = 0

    func calculateTotal() {
        var total = Float(0)
        DailyData.data.forEach { value in
            total += Float(value.power) * value.time
        }
        totalCost = Int(total * 1.262)
    }
    
    var body : some View{
        VStack{
            Text("Daily Usage")
                .font(.system(size : 32, weight : .bold))
                .frame(maxWidth : .infinity, alignment: .center)
                .foregroundStyle(Color("DarkestYellow"))
                
            VStack{
                Text("Rp.\(totalCost)")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color("Yellow"))
                
                Text("Daily Goal: Rp.\(totalCost)")
                    .font(.headline)
                    .foregroundStyle(Color("Green"))
            }.padding(.vertical, 20)
            
           
            
            HStack{
                Text("Device List")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("DarkestYellow"))
                Spacer()
                Button(action : {
                    DailyData.createData(data: [DeviceData(id : count, name : "", power :0, time : 0.0)])
                    count += 1
                    showDetail.toggle()
                                    
                }){
                    Label("Add", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(Color("DarkYellow"))
                }.background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color("Yellow"))
                )
            }.padding(.vertical , 10)
            
            ScrollView{
                LazyVGrid(columns: templateRow){
                    ForEach(columns, id : \.self ){ value in
                        Text(value)
                            .frame(maxWidth : .infinity, alignment : .leading)
                            .foregroundStyle(Color("DarkestYellow"))
                        
                    }
                    if DailyData.data.count > 0 {
                        ForEach(Array($DailyData.data.enumerated()), id : \.element.id){ count,$value in
                            
                            CircularProgressView(progress : 1, text : "\(count+1)", color : Color("Yellow"), padding : 3, textColor : Color("DarkestYellow"))
                            
                            
                            
                            TextField(
                                "Device Name",
                                text : $value.name
                            )
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5))
                            ).frame(maxWidth : .infinity)
                            
                            
                            TextField(
                                "Watt",
                                text : Binding(
                                    get : {String(value.power)=="0" ? "" : String(value.power)},
                                    set : { val in
                                        if let intValue = Int(val) {
                                            value.power = intValue
                                            calculateTotal()
                                        }
                                    }
                                )
                            )
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5))
                            ).frame(maxWidth : .infinity)
                            
                            TextField(
                                "Hrs",
                                text : Binding(
                                    get : {String(value.time) == "0.0" ? "" : String(value.time)},
                                    set : { val in
                                        if let intValue = Float(val) {
                                            value.time = intValue
                                            calculateTotal()
                                        }
                                    }
                                )
                            )
                            .padding(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.gray.opacity(0.5))
                            ).frame(maxWidth : .infinity)
                            
                            Button(action : {
                                
                                DailyData.deleteDailyUsage(id: value.id)
                                showDetail = false
                                
                            }){
                                Image(systemName : "minus.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .padding(7)
                                    .foregroundStyle(.gray)
                            }
                            .frame(width : 40.0, height : 40)
                            
                            
                            
                        }.frame(maxWidth : .infinity)
                            .transition(.asymmetric(insertion: .move(edge : .trailing), removal: .opacity))
                            .animation(.easeIn(duration: 0.2), value: DailyData.data.count)
                        }
                    }.frame(maxWidth : .infinity)
                        .padding(.trailing, 10)
                
            }
            
            
            Spacer()
            VStack{
                
                Button(action : {
                    DailyData.updateDailyUsage(data : DailyData.data)
                }){
                    Text("Save")
                        .padding(10)
                        .frame(maxWidth : .infinity, alignment : .center)
                        .foregroundStyle(Color("DarkYellow"))
                        .font(.title)
                        .bold(true)
                }
                .background(
                    RoundedRectangle(cornerRadius:50)
                        .fill(Color("Yellow"))
                )
                .frame(maxWidth : .infinity)
            }.frame(maxWidth : .infinity, alignment : .center)
        }
        .frame(maxWidth : .infinity, maxHeight : .infinity, alignment : .topLeading)
        .padding(.horizontal,25)
        .padding(.top, 30)
        .background()
        .onAppear {
            DailyData.loadData()
            calculateTotal()
        }.onReceive(DailyData.objectWillChange) { _ in
            calculateTotal()
        }.gesture(
            DragGesture()
                .onChanged { gesture in
                    print(gesture.translation)
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        print("Back")
                        route.currentPage = .home
                    } else {
                        offset = .zero
                    }
                }
        )
    }
    
}

#Preview {
    DailyUsageView()
}
