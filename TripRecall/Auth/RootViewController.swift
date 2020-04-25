//
//  RootViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 18/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import SnapKit
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialSnackbar

class RootViewController: UIViewController {
    @IBOutlet weak var emailText: MDCOutlinedTextField!
    @IBOutlet weak var passwordText: MDCOutlinedTextField!
    @IBOutlet weak var signInButton: MDCButton!
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var registerButton: MDCButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var headingView: UIView!
    let alert = UIAlertController(title: nil, message: "Please wait", preferredStyle: .alert)
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let message = MDCSnackbarMessage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        // Fit topview image
        imageView.image = UIImage(named: "logo.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        headingView.layer.masksToBounds = false
        headingView.layer.cornerRadius = 20
        headingView.backgroundColor = UIColor(rgb: 0xe9e9e9)
        
        loginView.layer.cornerRadius = 20
        let searchLayer = loginView.layer as! MDCShadowLayer
        searchLayer.elevation = ShadowElevation(10)
        
        emailText.label.text = "Email"
        emailText.setOutlineColor(UIColor(rgb: 0x0a173d), for: .editing)
        emailText.text = "patelbhhavya@gmail.com"
        
        passwordText.label.text = "Password"
        passwordText.setOutlineColor(UIColor(rgb: 0x0a173d), for: .editing)
        passwordText.text = "Bhavya123*"
        
        let containerScheme = MDCContainerScheme()
        signInButton.applyContainedTheme(withScheme: containerScheme)
        signInButton.backgroundColor = UIColor(rgb: 0x0a173d)
        
        registerButton.applyTextTheme(withScheme: containerScheme)
        registerButton.setTitleColor(UIColor(rgb: 0x0a173d), for: .normal)
        
        setupView()
        
        if let _ = UserDefaults.standard.value(forKey: "user_auth_token") {
            displayLoader(msg: "Please wait")
            fetchUserDetail { (status, error) in
                if let _ = status {
                    DispatchQueue.main.async {
                        self.dismissLoader(status: "success")
                    }
                }
            }
        }
    }
        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods

    private func displayLoader(msg: String) {
        alert.message = msg
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func dismissLoader(status: String) {
        dismiss(animated: true, completion: {
            if status == "success" {
                self.goToHomePage()
            } else {
                self.message.text = "Invalid Credential"
                MDCSnackbarManager.show(self.message)
            }
        })
    }
    
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
        
        passwordText.snp.makeConstraints() { (make) in
            make.top.equalTo(emailText.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        signInButton.snp.makeConstraints() { (make) in
            make.top.equalTo(passwordText.snp.bottom).offset(15)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(50)
        }
        
        registerLabel.snp.makeConstraints() { (make) in
            make.top.equalTo(signInButton.snp.bottom).offset(15)
            make.height.equalTo(15)
            make.centerX.equalTo(loginView)
        }
        
        registerButton.snp.makeConstraints() { (make) in
            make.top.equalTo(registerLabel.snp.bottom).offset(5)
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
    
    private func fetchUserDetail(completion: @escaping (String?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: "/v1/user/self", method: "GET", access: "private", body: nil) { (result, error) in
            
            if let result = result {
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.setDateFormat()
                    
                    self.appDelegate.user = try jsonDecoder.decode(User.self, from: result)
                    print("here10")
                    completion("success", nil)
                }
                catch {
                    completion(nil, error)
                    print("ERROR \(error)")
                }
            } else if let error = error {
                completion(nil, error)
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

    @IBAction func signin(_ sender: MDCButton) {
//        emailText.leadingAssistiveLabel.text = "Email is not valid"
//        emailText.leadingAssistiveLabel.reloadInputViews().self
        
        let user = User(email: emailText.text ?? "")
        user.password = passwordText.text
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(user)
            displayLoader(msg: "Logging in...")
            authentication(route: "/v1/user/auth", body: jsonData)
            if let _ = UserDefaults.standard.value(forKey: "user_auth_token") {
                fetchUserDetail { (status, error) in
                    if let _ = status {
                        DispatchQueue.main.async {
                            self.dismissLoader(status: "success")
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.dismissLoader(status: "failure")
                }
            }
        }
        catch {
            DispatchQueue.main.async {
                print("here4")
                self.dismissLoader(status: "failure")
            }
        }
    }
    
}
