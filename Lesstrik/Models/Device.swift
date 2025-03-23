//
//  DailyUsage.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 19/03/25.
//
import CoreData


class Device: ObservableObject {
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
                
                self.data.forEach{ da in
                    print(da.name)
                }
                if(self.data.count == 0 ){
                    self.createData(data: [DeviceData(id : 0, name : "" , power : 0, time : 0.0)])
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
    
    
    public func createData(data : [DeviceData]){
        DispatchQueue.global(qos: .background).async {
            self.context.perform{
                for devic in data{
                    devic.id = Int64(self.getNextID())
                    self.data.append(devic)
                }
            }
            
        }
    }
    
    
    func store(data : DeviceData){
        self.context.perform{
            let newData = Devices(context: self.context)
            newData.device_name = data.name
            newData.power = Int32(data.power)
            newData.power_time = Float(data.time)
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
    
    
    func deleteDailyUsage(id: Int) {
        let index = id
        print("\(index) \(data.count)")

        if index >= 0 && index < data.count {
            let request: NSFetchRequest<Devices> = Devices.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", data[index].id)
            do{
                let result = try context.fetch(request)
                if let deleteData = result.first{
                    self.context.delete(deleteData)
                    self.saveContext()
                }
            }catch{
                print("Error : Cannot delete data !")
            }
            
            data.remove(at: index)

        } else {
            print("Error: Index out of range")
        }
    }
}

