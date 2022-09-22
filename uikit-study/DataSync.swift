//
//  DataSync.swift
//  uikit-study
//
//  Created by kimjimin on 2022/09/22.
//

import UIKit
import CoreData
import Alamofire

class DataSync {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func downloadBackupData() {
        let ud = UserDefaults.standard
        guard ud.value(forKey: "firstLogin") == nil else { return }
        
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        let get = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        
        get.responseJSON { res in
            guard let jsonObject = try! res.result.get() as? NSDictionary else { return }
            guard let list = jsonObject["list"] as? NSArray else { return }
            
            for item in list {
                guard let record = item as? NSDictionary else { return }
                let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                object.title = (record["title"] as! String)
                object.contents = (record["contents"] as! String)
                object.regdate = self.stringToDate(record["create_date"] as! String)
                object.sync = true
                
                if let imagePath = record["image_path"] as? String {
                    let url = URL(string: imagePath)!
                    object.image = try! Data(contentsOf: url)
                }
            }
            
            do {
                try self.context.save()
            } catch let e as NSError {
                self.context.rollback()
                NSLog("An error has occured: %s", e.localizedDescription)
            }
            
            ud.setValue(true, forKey: "firstLogin")
        }
    }
}

// MARK: DataSync Util method
extension DataSync {
    func stringToDate(_ value: String) -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: value)!
    }
    
    func dateToString(_ value: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: value as Date)
    }
}
