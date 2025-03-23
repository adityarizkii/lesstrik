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
    
    
    
    
}
