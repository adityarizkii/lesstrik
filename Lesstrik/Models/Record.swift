//
//  Record.swift
//  Lesstrik
//
//  Created by Muhammad Chandra Ramadhan on 23/03/25.
//

import CoreData

class RecordType : ObservableObject, Equatable{
    static func == (lhs: RecordType, rhs: RecordType) -> Bool {
        return lhs.usage_goal == rhs.usage_goal && lhs.period == rhs.period && lhs.id == rhs.id
    }

    @Published var id:UUID
    @Published var period:String
    @Published var usage_goal:Int32
    
    init(id: UUID, period: String, usage_goal: Int32) {
        self.id = id
        self.period = period
        self.usage_goal = usage_goal
    }
}



class Record:ObservableObject{
    var context = CoreDataStack.shared.context
    
    //Fungsi buat ambil semua data record
    func getRecords(callback: @escaping (([RecordType]) -> Void)){
        DispatchQueue.global(qos : .background).async{
            self.context.perform{
                let request : NSFetchRequest<Records> = Records.fetchRequest()
                
                if let result = try? self.context.fetch(request){
                    let data = result.map{ value in
                        RecordType(
                            id : value.id ?? UUID(),
                            period : value.period ?? "" ,
                            usage_goal : value.usage_goal
                        )
                    }
                    callback(data)
                    print(data)
                }
            }
        }
    }
    
    
    //Fungsi buat ambil satu je data record
    func getRecords(period: String, callback: @escaping ((RecordType?) -> Void)
) {
        DispatchQueue.global(qos: .background).async {
            self.context.perform {
                let request: NSFetchRequest<Records> = Records.fetchRequest()
                request.predicate = NSPredicate(format: "period == %@", period as CVarArg)

                if let result = try? self.context.fetch(request), let _ = result.first {
                    DispatchQueue.main.async {
                        callback(
                            RecordType(
                                id : result.first!.id ?? UUID(),
                                period : result.first!.period ?? "",
                                usage_goal : result.first!.usage_goal
                            )
                        )
                        print("✅ Updated currentData: \(result.first!.usage_goal)")
                    }
                }
            }
        }
    }

    //Siimpan perubahan database
    func saveState(){
        do{
            try self.context.save()
        }catch{
            print("Awww snap : Error in saving state : \(error)")
        }
    }
    
    //Fungsi untuk tambahin 1 entry ke tabel
    func addRecord(data : RecordType){
        self.context.perform{
            let request : NSFetchRequest<Records> = Records.fetchRequest()
            request.predicate = NSPredicate(format: "period == %@", data.period as CVarArg)
            
            //Scan dulu ada data nya ngga
            do{
                let result = try self.context.fetch(request)
                
                if let record = result.first{
                    //Kalau ade update
                    record.usage_goal = data.usage_goal
                    self.saveState()
                }else{
                    //Kalau ngga ada tambah aje
                    let newRecord = Records(context : self.context)
                    newRecord.id = data.id
                    newRecord.period = data.period
                    newRecord.usage_goal = data.usage_goal
                    
                    self.saveState()
                    print("Berhasil menambahkan data !")
                    
                }
                
            }catch{
                print("Error checking record data : \(error.localizedDescription)")
            }
            
            
           
        }
    }
    
}
