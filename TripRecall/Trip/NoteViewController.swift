//
//  NoteViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 22/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit

class NoteViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var attraction: Attraction!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Note"
        if let _ = attraction.note {
            let barButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(updateNote))
            self.navigationItem.rightBarButtonItem  = barButton
            self.textView.text = self.attraction.note?.detail
        } else {
            noteAPI(route: "/v1/attraction/\(attraction._id!)/note", method: "GET", body: nil) { (status, error) in
                if let _ = status {
                    DispatchQueue.main.async {
                        let barButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(self.updateNote))
                        self.navigationItem.rightBarButtonItem  = barButton
                        self.textView.text = self.attraction.note?.detail
                    }
                } else if let _ = error {
                    DispatchQueue.main.async {
                        let barButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.saveNote))
                        self.navigationItem.rightBarButtonItem  = barButton
                        self.textView.text = self.attraction.note?.detail
                    }
                }
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        textView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.bottom.equalTo(-10)
        }
    }
    
    private func noteAPI(route: String, method: String, body: Data?, completion: @escaping (String?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: method, access: "public", body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.setDateFormat()
                        
                        self.attraction.note = try jsonDecoder.decode(Note.self, from: result)
                        
                        completion("success", nil)
                    }
                } catch let error {
                    completion(nil, error)
                    print(error.localizedDescription)
                }
                
            } else if let error = error {
                completion(nil, error)
            }
            group.leave()
        }
        group.wait()
    }
    
    // MARK: - Actions
    
    @objc func saveNote(){
        let note = Note(detail: textView.text ?? "")

        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
        
        do {
            let jsonData = try jsonEncoder.encode(note)
                    
            noteAPI(route: "/v1/attraction/\(attraction._id!)/note", method: "POST", body: jsonData) { (status, error) in
                if let _ = status {
                    
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if let e = error as? ResponseErrors {
                        print(e)
                } else {
                    print("fatal error")
                }
            }
        } catch {
            print("ERROR IN JSON PARSING \(error)")
        }
    }
    
    @objc func updateNote(){
        let note = Note(detail: textView.text ?? "")

        let jsonEncoder = JSONEncoder()
        jsonEncoder.setDateFormat()
        
        do {
            let jsonData = try jsonEncoder.encode(note)
                    
            noteAPI(route: "/v1/attraction/\(attraction._id!)/note/\(attraction.note!._id!)", method: "PUT", body: jsonData) { (status, error) in
                if let _ = status {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if let e = error as? ResponseErrors {
                        print(e)
                } else {
                    print("fatal error")
                }
            }
        } catch {
            print("ERROR IN JSON PARSING \(error)")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
