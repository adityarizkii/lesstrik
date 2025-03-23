//
//  DailyUsage.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 19/03/25.
//
import CoreData

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
    @Published var usage_id : UUID

    init(id: Int64, name: String, power: Int, time: Float, usage_id : UUID) {
        self.id = id
        self.name = name
        self.power = power
        self.usage_id = usage_id
        self.time = time
    }
}

class Device: ObservableObject {
    var context = CoreDataStack.shared.context
    
    func loadData(callback : @escaping (([DeviceData]) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            let fetchedData = self.getDailyUsage()
            DispatchQueue.main.async {
                let data = fetchedData.map { daily in
                    DeviceData(
                        id: daily.id ,
                        name: daily.device_name ?? "",
                        power: Int(daily.power),
                        time: daily.power_time,
                        usage_id: daily.usage_id ?? UUID()
                    )
                }
                
                callback(data)
               
            }
        }
    }
    
    func getDeviceByUsage(id : UUID, callback : @escaping (([DeviceData]) -> Void)){
        DispatchQueue.global(qos : .background).async{
            self.context.perform{
                let request: NSFetchRequest<Devices> = Devices.fetchRequest()
                request.predicate = NSPredicate(format: "usage_id == %@", id as CVarArg)
                
                if let device = try? self.context.fetch(request){
                    callback(
                        device.map { dev in
                            DeviceData(
                                id: dev.id ,
                                name: dev.device_name ?? "",
                                power: Int(dev.power),
                                time: dev.power_time,
                                usage_id : dev.usage_id ?? UUID()
                            )
                        }
                    )
                }
            }
        }
    }
    
    func getNextID() -> Int64 {
        let request: NSFetchRequest<Devices> = Devices.fetchRequest()
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
    
    public func getDailyUsage() -> [Devices] {
        do {
            let request: NSFetchRequest<Devices> = Devices.fetchRequest()
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
    
    
    func store(data : DeviceData){
        self.context.perform{
            let newData = Devices(context: self.context)
            newData.device_name = data.name
            newData.power = Int32(data.power)
            newData.power_time = Float(data.time)
            newData.usage_id = data.usage_id
            newData.id = data.id
            self.saveContext()
        }
    }
    
    func updateDailyUsage(data : [DeviceData]) {
        self.context.perform {
            data.forEach { device in
                print("\(device.id)  \(device.name)")
                let request: NSFetchRequest<Devices> = Devices.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", device.id)
                
                do {
                    let results = try self.context.fetch(request)
                    if let dailyUsage = results.first {
                        dailyUsage.device_name = device.name
                        dailyUsage.power = Int32(device.power)
                        dailyUsage.power_time = Float(device.time)
                        dailyUsage.usage_id = device.usage_id
                        
                        self.saveContext()
                    } else {
                        self.store(data : device)
                        print("Data tidak ditemukan untuk ID \(device.id)")
                    }
                } catch {
                    print("Gagal update data: \(error.localizedDescription)")
                }
            }
        }
        
    }
    
    
    func deleteDailyUsage(index: Int64) {
        let request: NSFetchRequest<Devices> = Devices.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", index as CVarArg)
        do{
            let result = try context.fetch(request)
            if let deleteData = result.first{
                self.context.delete(deleteData)
                self.saveContext()
            }
        }catch{
            print("Error : Cannot delete data !")
        }
            
          
    }
}

