//
//  Record.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 23/03/25.
//

import CoreData

class RecordType{
    @Published var id:UUID
    @Published var date:Date
    @Published var usage_goal:Int32
    
    init(id: UUID, date: Date, usage_goal: Int32) {
        self.id = id
        self.date = date
        self.usage_goal = usage_goal
    }
}


class Record:ObservableObject{
    var context = CoreDataStack.shared.context
    
    @Published var data:[RecordType] = []
    
    func getRecords(){
        DispatchQueue.global(qos : .background).async{
            self.context.perform{
                let request : NSFetchRequest<Records> = Records.fetchRequest()
                
                if let result = try? self.context.fetch(request){
                    self.data = result.map{ value in
                        RecordType(
                            id : value.id ?? UUID(),
                            date : value.date ?? Date(),
                            usage_goal : value.usage_goal
                        )
                    }
                    
                    print(self.data)
                }
            }
        }
    }
    
    
    func addRecord(data : RecordType){
        self.context.perform{
            do{
                let newRecord = Records(context : self.context)
                newRecord.id = data.id
                newRecord.date = data.date
                newRecord.usage_goal = data.usage_goal
                
                try self.context.save()
                print("Berhasil menambahkan data !")
            }catch{
                print("Error : \(error.localizedDescription)")
            }
        }
    }
    
}
