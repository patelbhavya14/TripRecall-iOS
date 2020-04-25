//
//  SearchTableViewController.swift
//  TripRecall
//
//  Created by Bhavya Patel on 20/04/20.
//  Copyright © 2020 teXoftgen. All rights reserved.
//

import UIKit
import GooglePlaces
import os.log

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    var placesClient: GMSPlacesClient!
    let token = GMSAutocompleteSessionToken.init()
    @IBOutlet weak var searchBar: UISearchBar!
    var searchResults:[Place] = []
    var action: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        
        placesClient = GMSPlacesClient.shared()
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
//        searchBar.setImage(UIImage(named: "back"), for: .search, state: .normal)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.tintColor = UIColor.theme()
        self.navigationItem.backBarButtonItem?.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Search bar delegate methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let filter = GMSAutocompleteFilter()

        self.placesClient?.findAutocompletePredictions(fromQuery: searchText,
                                                  filter: filter,
                                                  sessionToken: token,
                                                  callback: { (results, error) in
            if let error = error {
              print("Autocomplete error: \(error)")
              return
            }
            if let results = results {
              self.searchResults = []
              for result in results {
                let place = Place(place_id: result.placeID, place_name: result.attributedPrimaryText.string, place_location: result.attributedSecondaryText?.string)
                self.searchResults.append(place)
              }
            }
        })
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("nope")
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
        print("arey")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchResults.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! SearchTableViewCell

        // Configure the cell...
        
        let place = self.searchResults[indexPath.row]
        
        cell.placeNameLabel.text = place.place_name
        cell.placeLocationLabel.text = place.place_location ?? ""

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlace = searchResults[indexPath.row]
        let destVC = self.storyboard?.instantiateViewController(withIdentifier: "PlaceViewController") as! PlaceViewController
        destVC.place_id = selectedPlace.place_id
        destVC.action = self.action
        self.navigationController?.pushViewController(destVC, animated: true)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            case "SearchPlaceDisplay":
                guard let placeDetailViewController = segue.destination as? PlaceViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                guard let selectedPlaceCell = sender as? SearchTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                 
                guard let indexPath = tableView.indexPath(for: selectedPlaceCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                 
                let selectedPlace = searchResults[indexPath.row]
                placeDetailViewController.place_id = selectedPlace.place_id
                placeDetailViewController.action = self.action
            default:
                fatalError("Unexpected Segue Identifier;")
        }
    }


}
