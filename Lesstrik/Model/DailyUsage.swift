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
                        id: daily.id ,
                        name: daily.device_name ?? "",
                        power: Int(daily.power),
                        time: daily.power_time
                    )
                }
                
                print(self.data)
                if(self.data.count == 0 ){
                    self.createData(data: [DeviceData(id : 0, name : "" , power : 0, time : 0.0)])
                    self.loadData()
                }
            }
        }
    }
    
    func getNextID() -> Int64 {
        let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        request.fetchLimit = 1

        do {
            let lastEntry = try context.fetch(request).first
            return (lastEntry?.id ?? 0) + 1
        } catch {
            print("Gagal mendapatkan ID terbaru: \(error.localizedDescription)")
            return 1
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
    
    private func saveContext() {
        do {
            try context.save()
            print("Data batch berhasil disimpan!")
        } catch {
            print("Gagal menyimpan data batch: \(error.localizedDescription)")
        }
    }
    
    
    public func createData(data : [DeviceData]){
        DispatchQueue.global(qos: .background).async {
            self.context.perform{
                for devic in data{
                    let newData = DailyUsages(context: self.context)
                    newData.device_name = devic.name
                    newData.power = Int32(devic.power)
                    newData.power_time = devic.time
                    newData.id = self.getNextID()
                }
                
                self.saveContext()
                self.loadData()
            }
            
        }
    }
    
    func updateDailyUsage(id: Int64, newName: String, newPower: Int32, newTime: Float) {
        let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let results = try context.fetch(request)
            if let dailyUsage = results.first {
                dailyUsage.device_name = newName
                dailyUsage.power = newPower
                dailyUsage.power_time = newTime
                
                self.saveContext()
            } else {
                print("Data tidak ditemukan untuk ID \(id)")
            }
        } catch {
            print("Gagal update data: \(error.localizedDescription)")
        }
    }
    
    
    func deleteDailyUsage(id: Int64) {
        let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        do {
            let results = try context.fetch(request)
            if let dailyUsage = results.first {
                self.context.delete(dailyUsage)
                self.saveContext()
                self.loadData()
            } else {
                print("Data tidak ditemukan untuk ID \(id)")
            }
        } catch {
            print("Gagal menghapus data: \(error.localizedDescription)")
        }
    }
}

