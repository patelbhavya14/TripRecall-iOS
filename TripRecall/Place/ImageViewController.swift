//
//  ImageViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 24/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit

class ImageViewController: UIViewController {

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(5)
            make.left.equalTo(15)
        }
        
        imageView.image = image
        
        imageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func tap(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizer.Direction.right:
                print("Swiped right")
        case UISwipeGestureRecognizer.Direction.down:
                print("Swiped down")
        case UISwipeGestureRecognizer.Direction.left:
                print("Swiped left")
        case UISwipeGestureRecognizer.Direction.up:
                print("Swiped up")
            default:
                break
        }
    }
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}
