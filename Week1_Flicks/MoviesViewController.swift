//
//  MoviesViewController.swift
//  Week1_Flicks
//
//  Created by Ian Campelo on 10/17/16.
//  Copyright © 2016 Ian Campelo. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    
    var endpoint: String!
    
    var errorMsgView = UIView()
    var errorMsgLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        errorMsgView.frame = CGRect(x: 20, y: 64, width: tableView.frame.size.width, height: 30)
        errorMsgLabel.frame = CGRect(x: 20, y: 47, width: tableView.frame.size.width, height: 30)
        errorMsgView.backgroundColor = UIColor.red
        errorMsgLabel.text = "Network Error... Check your network Settings"
        errorMsgLabel.font = errorMsgLabel.font.withSize(17)
        errorMsgLabel.sizeToFit()
        errorMsgLabel.center = CGPoint(x: errorMsgView.frame.width/2, y: errorMsgView.frame.height/2)
        errorMsgView.insertSubview(errorMsgLabel, at: 0)
        errorMsgView.isHidden = true
        UIApplication.shared.keyWindow?.addSubview(errorMsgView)
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshControlAction(refreshControl:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 1)
        
        networkRequest()
        
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let movies = movies{
            return movies.count
        }else{
            return 0
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath as IndexPath) as! MovieCell
        
        let movie = movies?[indexPath.row]
        let title = movie?["title"] as! String
        let overview = movie?["overview"] as! String
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie?["poster_path"] as? String{
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.posterView.setImageWith(imageUrl! as URL)
        }
        
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        return cell
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func networkRequest(){
        let apiKey = "c6768baa56bd7dc9fb570f26f20cfc08"
        
        let urlR = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint!)?api_key=\(apiKey)")
        
        let request = URLRequest(url: urlR! as URL)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    
                    self.movies = responseDictionary["results"] as! [NSDictionary]?
                    self.tableView.reloadData()
                    
                    if(!self.errorMsgView.isHidden){
                        self.errorMsgView.isHidden = true
                    }
                    
                    MBProgressHUD.hide(for: self.view, animated: true)
                } else {
                    
                    
                }
            } else {
                self.tableView.reloadData()
                
                //if(self.errorMsgView.isHidden){
                self.errorMsgView.isHidden = false
                //}
                
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        networkRequest()
        self.refreshControl.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        let movie = movies?[(indexPath?.row)!]
        let detailVC = segue.destination as! DetailViewController
        
        detailVC.movie = movie
        
    }
    
}
