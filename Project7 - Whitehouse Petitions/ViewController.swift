//
//  ViewController.swift
//  Project7 - Whitehouse Petitions
//
//  Created by Vitali Vyucheiski on 3/17/22.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var petitionsToSort = [Petition]()
    var linkToShow = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Whitehouse Petitions"
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSortOptiones))
        let resetButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(resetPetitiones))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showSource))
        navigationItem.leftBarButtonItems = [resetButton, searchButton]
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        //let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            // urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        linkToShow = urlString
        
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url){
                    parse(json: data)
                    petitionsToSort = petitions
                    return
                }
            }
            
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func resetPetitiones() {
        petitionsToSort = petitions
        tableView.reloadData()
    }
    
    @objc func showSource() {
        let ac = UIAlertController(title: "Sourse", message: "All the shown petitions comes from: \(linkToShow)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showSortOptiones() {
        let ac = UIAlertController(title: "Search", message: "", preferredStyle: .alert)
        ac.addTextField()
                
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true, completion: nil)
    }
    
    func submit(_ answer: String) {
        petitionsToSort.removeAll()
        for petition in petitions {
            if petition.title.contains(answer) {
                petitionsToSort.append(petition)
            }
        }
        tableView.reloadData()
    }
    
    @objc func showError() {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitionsToSort.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitionsToSort[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitionsToSort[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

