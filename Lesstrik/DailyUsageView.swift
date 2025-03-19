//
//  DailyUsageView.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 18/03/25.
//
import SwiftUI


class DeviceData: ObservableObject, Identifiable {
    var id: Int
    @Published var name: String
    @Published var power: Int
    @Published var time: Float

    init(id: Int, name: String, power: Int, time: Float) {
        self.id = id
        self.name = name
        self.power = power
        self.time = time
    }
}

struct DailyUsageView:View{
    @State var count = 1
    
    let templateRow = [
        GridItem(.fixed(30)),
        GridItem(.flexible()),
        GridItem(.fixed( 50)),
        GridItem(.fixed(50)),
        GridItem(.fixed(30)),

    ]
    
    let columns = ["No", "Name" , "Power", "Time", ""];
    @State var data : [DeviceData] = [
        DeviceData(id : 0, name : "" , power : 0, time : 0.0)
    ];
    
    
    func calculate () -> Int{
        var total = Float(0);
            data.forEach{value in
                total += Float(value.power) * value.time
            }
       
        return Int( total * 1.262 ) ;
    }
    
    
    var body : some View{
        VStack{
            Text("Daily Usage")
                .font(.system(size : 32, weight : .bold))
                .frame(maxWidth : .infinity, alignment: .center)
            
            Text("Rp.\(calculate())")
                .font(.system(size : 38, weight : .bold))
                .padding(.vertical, 20)
            
            HStack{
                Text("Device List")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button(action : {
                    data.append(DeviceData(id : count, name : "", power :0, time : 0.0))
                    count += 1
                }){
                    Label("Add", systemImage: "plus")
                        .font(.system(size : 18, weight : .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                }.background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(.gray)
                )
            }.padding(.vertical , 10)
            
            ScrollView{
                LazyVGrid(columns: templateRow){
                    ForEach(columns, id : \.self ){ value in
                        Text(value)
                            .frame(maxWidth : .infinity, alignment : .leading)
                            
                    }
                    ForEach(Array($data.enumerated()), id : \.element.id){ count,$value in
                        
                        CircularProgressView(progress : 1, text : "\(count+1)", color : .gray, padding : 3)

                        
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
                            if data.count > 1 {
                                data.remove(at : count)
                            }
                        }){
                            Image(systemName : "minus.circle")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .padding(7)
                                .foregroundStyle(.gray)
                        }
                        .frame(width : 40.0, height : 40)

                        
                            
                    }.frame(maxWidth : .infinity)
                    
                }.frame(maxWidth : .infinity)
                    .padding(.trailing, 10)
            }
            
            
            
            
            Spacer()
            VStack{
//                HStack{
//                    Text("Estimate \nCost")
//                        .font(.system(size : 22, weight : .bold))
//                    Spacer()
//                    Text("Rp.Total cost")
//                        .font(.system(size : 30, weight : .bold))
//                }.frame(alignment : .center)
                
                Button(action : {}){
                    Text("Save")
                        .padding(10)
                        .frame(maxWidth : .infinity, alignment : .center)
                        .foregroundStyle(.white)
                        .font(.title)
                        .bold(true)
                }
                .background(
                    RoundedRectangle(cornerRadius:50)
                        .fill(Color.gray)
                )
                .frame(maxWidth : .infinity)
            }.frame(maxWidth : .infinity, alignment : .center)
        }
        .frame(maxWidth : .infinity, maxHeight : .infinity, alignment : .topLeading)
        .padding(.horizontal,25)
        .padding(.top, 30)
    }
    
}

#Preview {
    DailyUsageView()
}
