import SwiftUI



struct DailyUsageView: View {
    @EnvironmentObject var route: AppRoute
    @State var offset = CGSize.zero
    @State var count: Int64 = 1
    @State var showDetail = false
    @StateObject var device = Device()
    @FocusState var focusField: Bool
    @State var data: [DeviceData] = []
    @Binding var usageID : UUID

    
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
    
    
    @FocusState private var focusedIndex: Int?  // Tambahkan ini

    var body: some View {
        VStack {
            Text("Daily Usage")
                .font(.system(size: 32, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundStyle(Color("DarkestYellow"))

            VStack {
                Text("Rp.\(totalCost)")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(Color("Yellow"))

                Text("Daily Goal: Rp.\(totalCost)")
                    .font(.headline)
                    .foregroundStyle(Color("Green"))
            }
            .padding(.vertical, 20)

            HStack {
                Text("Device List")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(Color("DarkestYellow"))
                Spacer()
                Button(action: {
                    device.updateDailyUsage(data : data)
                    data.append(
                        DeviceData(
                            id: device.getNextID(),
                            name: "",
                            power: 0,
                            time: 0.0,
                            usage_id : usageID
                        )
                    )
                    count += 1
                    showDetail.toggle()
                }) {
                    Label("Add", systemImage: "plus")
                        .font(.headline)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(Color("DarkYellow"))
                }
                .background(RoundedRectangle(cornerRadius: 50).fill(Color("Yellow")))
            }
            .padding(.vertical, 10)

            ScrollView {
                LazyVGrid(columns: templateRow) {
                    ForEach(columns, id: \.self) { value in
                        Text(value)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Color("DarkestYellow"))
                    }

                    if !data.isEmpty {
                        ForEach(data.indices, id: \.self) { index in
                            if index < data.count {
                                CircularProgressView(progress: 1, color: Color("Yellow"), padding: 3, textColor: Color("DarkestYellow")) {
                                    Text("\(index + 1)")
                                }

                                TextField("Device Name", text: $data[index].name)
                                    .padding(5)
                                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5)))
                                    .frame(maxWidth: .infinity)
                                    .focused($focusedIndex, equals: index)  // Tambahkan ini

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
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5)))
                                .frame(maxWidth: .infinity)
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
                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(.gray.opacity(0.5)))
                                .frame(maxWidth: .infinity)
                                .focused($focusedIndex, equals: index)

                                Button(action: {
                                    focusedIndex = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        device.deleteDailyUsage(index : data[index].id)
                                        data.remove(at: index)
                                        showDetail = false
                                    }
                                }) {
                                    Image(systemName: "minus.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .padding(7)
                                        .foregroundStyle(.gray)
                                }
                                .frame(width: 40.0, height: 40)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .opacity))
                        .animation(.easeIn(duration: 0.2), value: data.count)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
            }

            Spacer()

            VStack {
                Button(action: {
                    device.updateDailyUsage(data: data)
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
        .background()
        .animation(.easeIn(duration: 2), value: route.currentPage)
        .onAppear {
            device.getDeviceByUsage(id: usageID){ result in
                print(usageID)
                data = result
                calculateTotal()

            }
        }
        .onReceive(device.objectWillChange) { _ in
            calculateTotal()
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        route.currentPage = .home
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            focusedIndex = nil  // Menutup keyboard saat area kosong diketuk
        }
    }

}

#Preview {
    DailyUsageView(usageID: .constant(UUID()))
        .environmentObject(AppRoute())
}
