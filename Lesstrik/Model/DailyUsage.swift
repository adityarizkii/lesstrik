//
//  DailyUsage.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 19/03/25.
//
import CoreData


class Daily: ObservableObject {
    var context = CoreDataStack.shared.context
    @Published var data: [DeviceData] = []

    init() {
        loadData()
    }

    func loadData() {
        DispatchQueue.global(qos: .background).async {
            let fetchedData = self.getDailyUsage()
            DispatchQueue.main.async {
                self.data = fetchedData.map { daily in
                    DeviceData(
                        id: daily.id,
                        name: daily.device_name ?? "",
                        power: Int(daily.power),
                        time: daily.power_time
                    )
                }
            
                print(self.data)
                if(self.data.count == 0 ){
                    self.data.append(DeviceData(id : 0, name : "" , power : 0, time : 0.0))
                }
            }
        }
    }

    public func getDailyUsage() -> [DailyUsages] {
        do {
            let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
            return try context.fetch(request)
        } catch {
            print("Failed to fetch daily usage: \(error.localizedDescription)")
            return []
        }
    }
}

