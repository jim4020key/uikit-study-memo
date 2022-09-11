//
//  MemoDAO.swift
//  uikit-study
//
//  Created by kimjimin on 2022/09/12.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch() -> [MemoData] {
        var memolist = [MemoData]()
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset {
                let data = MemoData()
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate! as Date
                data.objectID = record.objectID
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                
                memolist.append(data)
            }
        } catch let error as NSError {
            NSLog("An error has occured: %s", error.localizedDescription)
        }
        return memolist
    }
    
    func insert(_ data: MemoData) {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!
        if let image = data.image {
            object.image = image.pngData()!
        }
        
        do {
            try self.context.save()
        } catch let error as NSError {
            NSLog("An error has occured: %s", error.localizedDescription)
        }
    }
    
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        do {
            try self.context.save()
            return true
        } catch let error as NSError {
            NSLog("An error has occured: %s", error.localizedDescription)
            return false
        }
    }
}
