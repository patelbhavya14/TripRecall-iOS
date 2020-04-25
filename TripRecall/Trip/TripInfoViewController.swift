//
//  TripInfoViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 24/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons_Theming
import SnapKit
import MaterialComponents.MaterialSnackbar
import AWSS3
import AWSCore

class TripInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tripDetailButton: MDCButton!
    @IBOutlet weak var deleteTripButton: MDCButton!
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var uploadBtn: MDCButton!
    @IBOutlet weak var backBtn: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // UI Components
    let message = MDCSnackbarMessage()
    var images: [UIImage] = []
    var tabNo: Int!
    var trip: Trip!
    var placeImage: UIImage!
    
    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(TripPhotoCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let containerScheme = MDCContainerScheme()
        tripDetailButton.applyContainedTheme(withScheme: containerScheme)
        tripDetailButton.backgroundColor = UIColor.theme()
        
        deleteTripButton.applyContainedTheme(withScheme: containerScheme)
        deleteTripButton.backgroundColor = UIColor.theme()
        
        uploadBtn.applyContainedTheme(withScheme: containerScheme)
        uploadBtn.backgroundColor = UIColor.theme()
        
        tripNameLabel.text = trip.trip_name
        
        
        // Fit topview image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = placeImage
        
        // Set collection view
        view.addSubview(collectionView)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        
        // Download Images
        for (idx, p) in trip.photos!.enumerated() {
            downloadImage(bucketName: "triprecall", fileName: p.url) { (image, error) in
                if let i = image {
                    self.images.append(i)
                } else if let error = error {
                    print("download error \(error)")
                }
            }
            if idx+1 == trip.photos!.count {
                self.collectionView.reloadData()
            }
            
        }
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        topView.snp.makeConstraints() { (make) in
            make.left.top.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(250)
        }
        
        backBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(5)
            make.left.equalTo(15)
        }
        
        tripNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
        }
        
        imageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(0)
        }
        
        deleteTripButton.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(50)
            make.width.equalTo(view).multipliedBy(0.4)
        }
        
        uploadBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.right.equalTo(-15)
            make.height.equalTo(50)
            make.width.equalTo(view).multipliedBy(0.4)
        }
        
        tripDetailButton.snp.makeConstraints { (make) in
            make.top.equalTo(deleteTripButton.snp.bottom).offset(10)
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.height.equalTo(50)
        }
        
        photoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tripDetailButton.snp.bottom).offset(15)
            make.left.equalTo(15)
        }
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(photoLabel.snp.bottom).offset(0)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-10)
        }
    }
    
    private func tripAPI(route: String, method: String, access: String, body: Data?, completion: @escaping (Any?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        getDataFromAPI(route: route, method: method, access: access, body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        if method == "DELETE" {
                            completion("deleted", nil)
                        } else {
                            let jsonDecoder = JSONDecoder()
                            jsonDecoder.setDateFormat()
                            
                            let photo = try jsonDecoder.decode(Photo.self, from: result)
                            self.trip.photos?.append(photo)
                            completion(photo, nil)
                        }
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
    
    private func uploadPhoto(route: String, method: String, access: String, body: Data?, completion: @escaping (Photo?, Any?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        uploadPhotoAPI(route: route, method: method, boundary: access, body: body) { (result, error) in
            if let result = result {
                do {
                    //create json object from data
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.setDateFormat()
                            
                        let photo = try jsonDecoder.decode(Photo.self, from: result)
                        self.trip.photos?.append(photo)
                        completion(photo, nil)
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
    
    func downloadImage(bucketName: String, fileName: String, completion: @escaping (_ image: UIImage?, _ error: NSError?) -> Void) {
        let group = DispatchGroup()
        group.enter()
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
           identityPoolId:"")

        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)

        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        let transferUtility = AWSS3TransferUtility.default()

        transferUtility.downloadData(fromBucket: bucketName, key: fileName, expression: nil) { (task, url, data, error) in
            var resultImage: UIImage?

            if let data = data {
                resultImage = UIImage(data: data)
            }
            
            group.leave()
            completion(resultImage, error as NSError?)
        }
        group.wait()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
//        photoImageView.image = selectedImage
        
        var data = Data()

        let boundary = UUID().uuidString
        
        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(selectedImage.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        self.uploadPhoto(route: "/v1/trip/\(trip._id!)/photo", method: "POST", access: boundary, body: data) { (status, error) in
            if let _ = status {
                self.images.append(selectedImage)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Actions
    @IBAction func tripDetailAction(_ sender: Any) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "AttractionViewController") as! AttractionViewController
        destVC.trip = self.trip
        destVC.tabNo = self.tabNo
        self.navigationController?.pushViewController(destVC, animated: true)
        
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        self.tripAPI(route: "/v1/trip/\(trip._id!)", method: "DELETE", access: "private", body: nil) { (status, error) in
            if let _ = status {
                DispatchQueue.main.async {
                    self.appDelegate.user?.removeTrip(trip: self.trip)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func back(_ sender: Any) {
         self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func uploadAction(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
}

extension TripInfoViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.bounds.width/2.5, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TripPhotoCell
        
        cell.cornerRadius = 8
        
        cell.image.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        destVC.image = images[indexPath.row]
        self.navigationController?.pushViewController(destVC, animated: true)
    }
}

class TripPhotoCell: MDCCardCollectionCell {
    
    let image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 6
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(image)
        
        image.snp.makeConstraints { (make) in
            make.edges.equalTo(0)
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


