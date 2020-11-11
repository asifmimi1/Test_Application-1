//
//  TestVC.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 11/5/20.
//

import UIKit

class TestVC: UIViewController {
    @IBOutlet weak var nameLbl: UILabel!
    
    var Name : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("AAAAAAAAA:-\(Name)")
        nameLbl?.text = Name
        
    }
    override func viewWillAppear(_ animated: Bool) {
        print("AAAAAAAAA:-\(Name)")
        nameLbl?.text = Name
    }

}

