import SwiftUI



struct DailyUsageView: View {
    @EnvironmentObject var route: AppRoute
    @State var offset = CGSize.zero
    @State var count: Int64 = 1
    @State var showDetail = false
    @StateObject var device = Device()
    @StateObject var daily = DailyUsage()
    @FocusState var focusField: Bool
    @State var data: [DeviceData] = []
    @Binding var usageData : DailyUsageModel

    
    let templateRow = [
        GridItem(.fixed(30)),
        GridItem(.flexible()),
        GridItem(.fixed(50)),
        GridItem(.fixed(50)),
        GridItem(.fixed(30)),
    ]
    
    let columns = ["No", "Name", "Power", "Time", ""]
    @State var totalCost: Int = 0

    func calculateTotal() {
        var total = Float(0)
        data.forEach { value in
            total += Float(value.power) * value.time
        }
       
        totalCost = Int(total * 1.262)
    }
    
    
    
    
    @FocusState private var focusedIndex: Int?

    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                Button {
                    route.currentPage = .home
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .font(.title2)
                            .bold(true)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .foregroundStyle(.black)
                }
                .padding(.top, 40)
                Spacer()
            }
            .zIndex(1)
            .padding(.top, 10)
            .ignoresSafeArea()

            
            Image("Background")
                .resizable()
                .frame(height: UIScreen.main.bounds.height * 0.3)
                .clipShape(BottomRoundedShape(radius: 30))
                .ignoresSafeArea()
            VStack {
                Text("Daily Usage")
                    .font(.system(.largeTitle, weight: .bold))
                    .foregroundStyle(.black)
                VStack {
                    Text("Rp\(totalCost)")
                        .font(.system(.title, weight: .semibold))
                        .padding(.bottom, 4)
                        .foregroundStyle(.black)
                    
                    Text("Daily Goal : Rp\(totalCost)")
                        .font(.system(.title3))
                        .foregroundStyle(.black)
                }
                .padding(.vertical, 20)
                
                HStack {
                    Text("Device List")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {
                        data.append(
                            DeviceData(
                                id: device.getNextID(),
                                name: "",
                                power: 0,
                                time: 0.0,
                                usage_id : usageData.id
                            )
                        )
                        device.updateDailyUsage(data : data)
                        count += 1
                        showDetail.toggle()
                    }) {
                        Label("Add", systemImage: "plus")
                            .font(.headline)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    .background(RoundedRectangle(cornerRadius: 50).fill(Color("Yellow")))
                    .foregroundStyle(.black)
                }
                .padding(.vertical, 10)
                
                ScrollView {
                    LazyVGrid(
                        columns: templateRow
                    ) {
                        ForEach(columns, id: \.self) { value in
                            Text(value)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                       
                        
                        if !data.isEmpty {
                            ForEach(data.indices, id: \.self) { index in
                                if index < data.count {
                                    Text("\(index + 1)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    TextField("Device Name", text: $data[index].name)
                                        .padding(5)
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                                        .frame(maxWidth: .infinity)
                                        .background(.gray.opacity(0.1))
                                        .focused($focusedIndex, equals: index)
                                    
                                    TextField("Watt", text: Binding(
                                        get: { String(data[index].power) == "0" ? "" : String(data[index].power) },
                                        set: { val in
                                            if let intValue = Int(val) {
                                                data[index].power = intValue
                                                calculateTotal()
                                            }
                                        }
                                    ))
                                    .padding(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.1))
                                    .focused($focusedIndex, equals: index)
                                    
                                    TextField("Hrs", text: Binding(
                                        get: { String(data[index].time) == "0.0" ? "" : String(data[index].time) },
                                        set: { val in
                                            if let floatValue = Float(val) {
                                                data[index].time = floatValue
                                                calculateTotal()
                                            }
                                        }
                                    ))
                                    .padding(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray))
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.1))
                                    .focused($focusedIndex, equals: index)
                                    
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            focusedIndex = nil
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                device.deleteDailyUsage(index : data[index].id)
                                              
                                                data.remove(at: index)
                                                device.updateDailyUsage(data: data)
                                                calculateTotal()

                                                showDetail = false
                                            }
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .padding(7)
                                                .foregroundStyle(.red.opacity(0.6))
                                        }
                                        .frame(width: 40, height: 40)
                                    }
                                }
                            }
                            
                            .frame(maxWidth: .infinity)
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                            .animation(.easeIn(duration: 0.2), value: data.count)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, 10)
                    
                    
                    if(data.isEmpty) {
                        Text("No Device List in this day.")
                            .padding(.top, 32)
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        device.updateDailyUsage(data: data)
                        daily.update(data : DailyUsageModel(
                            id: usageData.id,
                            date: usageData.date,
                            totalCost: Int32(totalCost)
                        )){ error, message in
                            print(message)
                            route.currentPage = .home
                            
                        }
                    }) {
                        Text("Save")
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundStyle(Color("DarkYellow"))
                            .font(.title)
                            .bold()
                    }
                    .background(RoundedRectangle(cornerRadius: 50).fill(Color("Yellow")))
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 25)
            .padding(.top, 30)
            .animation(.easeIn(duration: 2), value: route.currentPage)
            .onAppear {
                print("Current : \(usageData.date)")
                device.getDeviceByUsage(id: usageData.id){ result in
                    print(usageData.id)
                    data = result
                    calculateTotal()
                    
                }
            }
            .onReceive(device.objectWillChange) { _ in
                calculateTotal()
            }
            .onTapGesture {
               focusedIndex = nil
           }
    
            
        }
        
    }

}

#Preview {
    DailyUsageView(
        usageData: .constant(
            DailyUsageModel(
                id : UUID(),
                date : Date.now,
                totalCost : 0
            )
        )
    ).environmentObject(AppRoute())
}
