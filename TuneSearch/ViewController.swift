//
//  ViewController.swift
//  TuneSearch
//
//  Created by Srini Motheram on 2/5/17.
//  Copyright © 2017 Srini Motheram. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var albumArray = [AlbumItem]()
    
    //MARK :- LIFE CYCLE METHODS
    
    let hostName = "itunes.apple.com"
    var reachability :Reachability?
    
    @IBOutlet var networkStatusLabel    :UILabel!
    @IBOutlet var searchField           :UITextField!
    @IBOutlet var albumTableView        :UITableView!
    
    //MARK :- CORE METHODS
    func parseJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print("JSON: \(jsonResult)")
            let flavorsArray = jsonResult["flavors"] as! [[String:Any]]
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict)")
            }
            for flavorDict in flavorsArray {
                print("Flavor:\(flavorDict["name"])")
            }
            
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func parseItunesJason(data: Data){
        
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print("JSON: \(jsonResult)")
            let songsArray = jsonResult["results"] as! [[String:Any]]
            for songsDict in songsArray {
                print("Song:\(songsDict)")
            }
            for songsDict in songsArray {
                print("Flavor:\(songsDict["trackName"])")
                albumArray.append(AlbumItem(artist: "\(songsDict["artistName"])",
                    album: "\(songsDict["collectionName"])",
                    song: "\(songsDict["trackName"])") ) }
            albumTableView?.reloadData()
            print("Album Array: \(albumArray)")
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func getFile(filename: String){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "http://\(hostName)\(filename)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let recvData = data else {
                print ("no data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                
            }
            if recvData.count > 0 && error == nil {
                
                print("Got Data: \(recvData)")
                let dataString = String.init(data: recvData, encoding: .utf8)
                print("Got Data String: \(dataString)")
                self.parseItunesJason(data: recvData)
                
            } else {
                print("Got data of length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
            }
        }
        task.resume()
    }
    
    //MARK: - setup METHODS -- just for testing
    func fillArray() -> [AlbumItem]{
        let album3 = AlbumItem(artist: "Bill", album: "jethrotull", song: "thick as a brick")
        let album2 = AlbumItem(artist: "Joe", album: "acqualong", song: "no clue")
        let album1 = AlbumItem(artist: "srini", album: "jethrotull", song: "a song")
        return [album1, album2, album3]
    }

    
    @IBAction func getFilePressed(button: UIButton){
        guard let reach = reachability else {
            return
        }
        guard let searchTerm = searchField.text else {
            return
        }
        if reach .isReachable {
            // getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
           // getFile(filename: "/classfiles/flavors.json")
            getFile(filename: "/search?term=\(searchTerm)")
            
        } else {
            print("Host Not reachable. Turn on the internet")
        }
        
        
    }
    
    //MARK :- Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return albumArray.count
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumTableViewCell
        let currentAlbumItem = albumArray[indexPath.row]
        cell.artistNameLabel.text = currentAlbumItem.artistName
        cell.albumNameLabel.text = currentAlbumItem.albumName
        cell.songNameLabel.text = currentAlbumItem.songName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentAlbumItem = albumArray[indexPath.row]
        print("Row: \(indexPath.row) \(currentAlbumItem.artistName)")
    }
 
    
    //MARK :- REACHABILITY METHODS
    
    func setupReachability(hostName: String){
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: true, reachability: reachability)
            }
        }
        reachability!.whenUnreachable = { reachability in
            DispatchQueue.main.async {
                self.updateLabel(reachable: false, reachability: reachability)
            }
        }
        
    }
    
    func startReachability(){
        do {
            try reachability!.startNotifier()
        } catch {
            networkStatusLabel.text = "Unable to start notifier"
            networkStatusLabel.textColor = .red
            return
        }
    }
    
    func updateLabel(reachable: Bool, reachability: Reachability){
        if reachable {
            if reachability.isReachableViaWiFi {
                networkStatusLabel.textColor = .green
            } else {
                networkStatusLabel.textColor = .blue
            }
        } else {
            networkStatusLabel.textColor = .red
        }
        networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability(hostName: hostName)
        startReachability()
        // albumArray = fillArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}



