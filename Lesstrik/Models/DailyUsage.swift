//
//  DailyUsages.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 22/03/25.
//
import CoreData

class DailyUsageModel : ObservableObject {
    @Published var id : UUID
    @Published var date : Date
    @Published var totalCost : Int32
    
    init(id: UUID, date: Date, totalCost: Int32) {
        self.id = id
        self.date = date
        self.totalCost = totalCost
    }
}

class DailyUsage : ObservableObject{
    var context = CoreDataStack.shared.context
        
    func getDailyUsages(callback : @escaping (([DailyUsageModel]) -> Void)){
        DispatchQueue.global(qos : .background).async {
            self.context.perform{
                let request:NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
                if let result = try? self.context.fetch(request){
                    let dailyUsages =  result.map{ daily in
                        DailyUsageModel(
                            id : daily.id ?? UUID(),
                            date : daily.date ?? Date(),
                            totalCost : daily.totalCost
                        )
                    }
                    
                    callback(dailyUsages)
                    
                    print(dailyUsages)
                }
                
            }
        }
    }
    
    func fetchDailyUsagesByMonth(year: Int, month: Int, callback: @escaping (([DailyUsageModel]?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            self.context.perform {
                let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
                
                let calendar = Calendar.current
                
                var startComponents = DateComponents()
                startComponents.year = year
                startComponents.month = month
                startComponents.day = 1
                let startOfMonth = calendar.date(from: startComponents)!

                let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
                var endComponents = startComponents
                endComponents.day = range.count
                let endOfMonth = calendar.date(from: endComponents)!

                request.predicate = NSPredicate(format: "date >= %@ AND date <= %@", startOfMonth as NSDate, endOfMonth as NSDate)

                if let result = try? self.context.fetch(request) {
                    let dailyUsageModel = result.map { val in
                        DailyUsageModel(
                            id: val.id ?? UUID(),
                            date: val.date ?? Date(),
                            totalCost: val.totalCost
                        )
                    }
                    callback(dailyUsageModel)
                } else {
                    callback([])
                }
            }
        }
    }

    
    func getDailyUsagesByDate(date: Date, callback: @escaping ((DailyUsageModel?) -> Void)) {
        DispatchQueue.global(qos: .background).async {
            self.context.perform {
                let request: NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

                request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

                if let result = try? self.context.fetch(request), let daily = result.first {
                    let dailyUsageModel = DailyUsageModel(
                        id: daily.id ?? UUID(),
                        date: daily.date ?? Date(),
                        totalCost: daily.totalCost
                    )
                    callback(dailyUsageModel)
                } else {
                    callback(nil)
                }
            }
        }
    }

    
    //fungsi buat nambahin data daily usage
    func create(data: DailyUsageModel, callback : @escaping ((Bool, String) -> Void)){
        DispatchQueue.global(qos : .background).async{
            self.context.perform{
                
                do{
                    let newData = DailyUsages(context : self.context)
                    newData.id = data.id
                    newData.date = data.date
                    newData.totalCost = data.totalCost
                    
                    try self.context.save()
                    
                    callback(false, "Berhasil menambahkan data !")
                    print("Berhasil menambahkan data")
                    
                }catch{
                    callback(true, "Gagal menambahkan data \(error.localizedDescription)")
                }
            }
            
        }
    }
    
    //Fungsi buat update data daily usage
    func update(data : DailyUsageModel, callback : @escaping ((Bool, String) -> Void)){
        DispatchQueue.global(qos : .background).async{
            self.context.perform{
                let request:NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", data.id as CVarArg )
                
                do{
                    let result = try self.context.fetch(request)
                    
                    if result.count > 0 {
                        let updateData = result[0]
                        updateData.date = data.date
                        updateData.totalCost = data.totalCost
                        callback(false , "Berhasil mengupdate data !")
                        return
                    }
                    callback(true, "Data tidak ditemukan !")
                }catch{
                    callback(true, "Error Gagal mengupdate data :  \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    
}
