//
//  ProductDetailVC.swift
//  Test_Application_1
//
//  Created by Asif Mimi on 11/4/20.
//

import UIKit

class ProductDetailVC: UIViewController {
    
    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var prodName: UILabel!
    @IBOutlet weak var prodPrice: UILabel!
    @IBOutlet weak var prodDescription: UILabel!
    @IBOutlet weak var companyName: UILabel!
    
    var url = ""
    var proName = ""
    var proDes = ""
    var proPrice = ""
    var comName = ""
    var proImg = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //let url = UserDefaults.standard.object(forKey: "url")
        //prodImage.image = proImage
        prodName.text = proName
        prodPrice.text = proPrice
        prodDescription.text = proDes
        companyName.text = comName
        prodImage.sd_setImage(with: URL(string: proImg))
    }

}
