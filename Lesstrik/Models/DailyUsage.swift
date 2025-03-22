//
//  DailyUsages.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 22/03/25.
//
import CoreData

struct DailyUsageModel {
    var id : UUID
    var date : Date
    var totalCost : Int32
}

class DailyUsage : ObservableObject{
    var context = CoreDataStack.shared.context
    
    
    
    @Published var dailyUsages: [DailyUsageModel] = []
    
    func getDailyUsages(){
        DispatchQueue.global(qos : .background).async {
            self.context.perform{
                let request:NSFetchRequest<DailyUsages> = DailyUsages.fetchRequest()
                if let result = try? self.context.fetch(request){
                    self.dailyUsages =  result.map{ daily in
                        DailyUsageModel(
                            id : daily.id!,
                            date : daily.date!,
                            totalCost : daily.totalCost
                        )
                    }
                    
                    print(self.dailyUsages)
                }
                
            }
        }
    }
}
