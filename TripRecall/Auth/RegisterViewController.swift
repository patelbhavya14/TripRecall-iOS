//
//  RegisterViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 19/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialTabs
import SnapKit
import MaterialComponents.MaterialButtons_Theming

class RegisterViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var headingView: UIView!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailText: MDCOutlinedTextField!
    @IBOutlet weak var nameText: MDCOutlinedTextField!
    @IBOutlet weak var passwordText: MDCOutlinedTextField!
    @IBOutlet weak var signUpButton: MDCButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: MDCButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        imageView.image = UIImage(named: "plane-bg")
                
        headingView.layer.masksToBounds = false
        headingView.layer.cornerRadius = 20
                
        loginView.layer.cornerRadius = 20
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowOpacity = 1
        loginView.layer.shadowRadius = 10
        loginView.layer.masksToBounds = true
                
        emailText.label.text = "Email"
        emailText.setOutlineColor(UIColor(rgb: 0x0a173d), for: .editing)
        
        nameText.label.text = "Name"
        emailText.setOutlineColor(UIColor(rgb: 0x0a173d), for: .editing)
        
        passwordText.label.text = "Password"
        passwordText.setOutlineColor(UIColor(rgb: 0x0a173d), for: .editing)
        
        let containerScheme = MDCContainerScheme()
        signUpButton.applyContainedTheme(withScheme: containerScheme)
        signUpButton.backgroundColor = UIColor(rgb: 0x0a173d)
        
        loginButton.applyTextTheme(withScheme: containerScheme)
        loginButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        
        setupView()

    }
    
    // MARK: - Private Methods

    private func setupView() {
        
        imageView.snp.makeConstraints() { (make) in
            make.left.topMargin.equalTo(-2)
            make.right.equalTo(0)
            make.height.equalTo(300)
        }
        
        bottomView.snp.makeConstraints() { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.bottom.left.right.equalTo(0)
        }
        
        headingView.snp.makeConstraints() { (make) in
            make.top.equalTo(0).offset(-50)
            make.left.right.equalTo(0)
            make.height.equalTo(100)
        }
        
        heading.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.centerX.equalTo(headingView)
        }
        
        loginView.snp.makeConstraints { (make) in
            make.top.equalTo(headingView.snp.bottom).offset(-30)
            make.bottom.right.left.equalTo(0)
        }
        
        emailText.snp.makeConstraints() { (make) in
            make.top.equalTo(30)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        nameText.snp.makeConstraints() { (make) in
            make.top.equalTo(emailText.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        passwordText.snp.makeConstraints() { (make) in
            make.top.equalTo(nameText.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        signUpButton.snp.makeConstraints() { (make) in
            make.top.equalTo(passwordText.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(50)
        }
        
        loginLabel.snp.makeConstraints() { (make) in
            make.top.equalTo(signUpButton.snp.bottom).offset(15)
            make.height.equalTo(15)
            make.centerX.equalTo(loginView)
        }
        
        loginButton.snp.makeConstraints() { (make) in
            make.top.equalTo(loginLabel.snp.bottom).offset(5)
            make.height.equalTo(15)
            make.centerX.equalTo(loginView)
        }
    }
    
    private func authentication(route: String, body: Data) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: "POST", access: "public", body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: result, options: .mutableContainers) as? Dictionary<String, Any> {
                        if let token = json as? Dictionary<String, String> {
                            UserDefaults.standard.setValue(token["token"]!, forKey: "user_auth_token")
                        }
                    }
                } catch let error {
                    print(error.localizedDescription)
                }
                
            } else if let error = error {
                print(error)
            }
            group.leave()
        }
        group.wait()
    }
    
    private func fetchUserDetail() {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: "/v1/user/self", method: "GET", access: "private", body: nil) { (result, error) in
            if let result = result {
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.setDateFormat()
                    
                    self.appDelegate.user = try jsonDecoder.decode(User.self, from: result)
                    print("Name : \(self.appDelegate.user!.username ?? "")")
                    print("Rating : \(self.appDelegate.user!.email)")
                }
                catch {
                    print("ERROR \(error)")
                }
            } else if let error = error {
                print(error)
            }
            group.leave()
        }
        group.wait()
    }
    
    private func goToHomePage() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButtonAction(_ sender: MDCButton) {
        let user = User(email: emailText.text ?? "")
        user.password = passwordText.text
        user.username = nameText.text
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            authentication(route: "/v1/user", body: jsonData)
            fetchUserDetail()
            goToHomePage()
        }
        catch {
        }
    }
    
}
