//
//  MemoData.swift
//  uikit-study
//
//  Created by kimjimin on 2022/07/11.
//

import UIKit
import CoreData

class MemoData {
    var memoIdx : Int?
    var title : String?
    var contents : String?
    var image : UIImage?
    var regdate : Date?
    
    var objectID: NSManagedObjectID?
}
