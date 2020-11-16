//
//  DatabaseHelper.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 11/15/20.
//

import Foundation
import UIKit
import CoreData

class DatabaseHelper {
    static let instance = DatabaseHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveImageInCoreData(at imgData: String) {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: context) as! Profile
        profile.name = imgData
        do{
            try context.save()
        }catch{
            print(error.localizedDescription)
        }
    }
}
