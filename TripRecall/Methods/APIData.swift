//
//  APIData.swift
//  TripRecall
//
//  Created by Bhavya Patel on 19/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import Foundation
import UIKit

func getDataFromAPI(route: String, method: String, access: String, body: Data?, completion: @escaping (Data?, ResponseErrors?) -> Void) {

    let url = URL(string: "https://triprecall.texoftgen.me"+route)!
    var request = URLRequest(url: url)

    request.httpMethod = method
    request.httpBody = body
    request.setValue(UserDefaults.standard.value(forKey: "user_auth_token") as? String , forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data,
            let response = response as? HTTPURLResponse,
            error == nil else {                                              // check for fundamental networking error
            print("error", error ?? "Unknown error")
                completion(nil, ResponseErrors())
            return
        }

        guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
            print("statusCode should be 2xx, but is \(response.statusCode)")
            print("response = \(data)")
            var errors = ResponseErrors()
            do {
                let jsonDecoder = JSONDecoder()
                errors = try jsonDecoder.decode(ResponseErrors.self, from: data)
                
                for e in errors.errors {
                    print(e.msg)
                }
            }
            catch {
                print("ERROR IN JSON ERROR \(error)")
            }
            completion(nil, errors)
            return
        }
        
        completion(data, nil)
    }
    task.resume()
}
