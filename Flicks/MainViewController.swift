//
//  MainViewController.swift
//  Flicks
//
//  Created by Huynh Tri Dung on 7/9/16.
//  Copyright © 2016 Huynh Tri Dung. All rights reserved.
//  TODO: Redesign the UI
//  TODO: Use swifty JSON
//  TODO: use collection view for grid/list layout
//  TODO: add place holder image for both screen


import UIKit
import AFNetworking
import MBProgressHUD


class MainViewController: UIViewController{

    @IBOutlet weak var lblNetworkErorr: UILabel!
    @IBOutlet weak var tableView: UITableView!

    let searchController = UISearchController(searchResultsController: nil)
    let API_KEY = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    var movies = [NSDictionary]()
    var movieSearchResult = [NSDictionary]()
    var endPoint = ""
    let reachability = Reachability.reachabilityForInternetConnection()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.tabBarController?.tabBar.barTintColor = UIColor.darkTextColor()
        navigationController?.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
//        navigationController?.hidesBarsOnSwipe = true
        navigationItem.titleView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find your favorite movies..."
        searchController.searchBar.barStyle = UIBarStyle.Black
        searchController.searchBar.backgroundColor = UIColor.darkTextColor()
        definesPresentationContext = false
        

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.backgroundColor = UIColor.darkTextColor()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        fetchData()
        
        lblNetworkErorr.hidden = true

//        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundView?.backgroundColor = UIColor.darkTextColor()
        tableView.tableHeaderView?.backgroundColor = UIColor.darkTextColor()
        
        //Set color for Cancel button in search bar
        (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
        
    }
    
    // MARK:Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let detailMoviewVC = segue.destinationViewController as! DetailMovieViewController
        
        let indexPath = tableView.indexPathForSelectedRow

        let movie:NSDictionary
        
        if searchController.active && searchController.searchBar.text != "" {
            movie = movieSearchResult[indexPath!.row]
        } else {
            movie = movies[indexPath!.row]
        }
        
        detailMoviewVC.movie = movie

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
    }
    
    // MARK:Private methods
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(API_KEY)")
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
//        self.view.endEditing(true)

        if reachability.isReachable() || reachability.isReachableViaWiFi() || reachability.isReachableViaWWAN(){
//            refreshControl.beginRefreshing()
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {
                (data, response, error) in
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data!, options:[]) as? NSDictionary {
                            self.lblNetworkErorr.hidden = true
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            
                            let dateFormatter = NSDateFormatter()
                            dateFormatter.dateFormat = "MMM d, h:mm a"
                        
                            let refreshInfo = "Last update: \(dateFormatter.stringFromDate(NSDate()))"
                            refreshControl.attributedTitle = NSAttributedString(string: refreshInfo,
                                attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
                            self.tableView.reloadData()
                            print("refresh done")
                            refreshControl.endRefreshing()
                        }
            });
            task.resume()
        }
        else {
            self.lblNetworkErorr.hidden = false
//            refreshControl.endRefreshing()
        }
    }
    
    func fetchData() {
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(API_KEY)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )

        if reachability.isReachable() || reachability.isReachableViaWiFi() || reachability.isReachableViaWWAN(){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {
                (dataOrNil, response, error) in
                if let data = dataOrNil {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    self.lblNetworkErorr.hidden = true
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.tableView.reloadData()
                    }
                }
            });
            task.resume()
        }
        else {
            lblNetworkErorr.hidden = false
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
//            let noDataLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.frame.size.height/2))
//            noDataLabel.textAlignment = NSTextAlignment.Center
////            noDataLabel.backgroundColor = UIColor.darkTextColor()
//            noDataLabel.textColor = UIColor.whiteColor()
//            noDataLabel.font.fontWithSize(40)
//            noDataLabel.text = ""
            if movieSearchResult.count < 1 {
//                noDataLabel.text = "No Results"
//                tableView.backgroundView = noDataLabel
                return movieSearchResult.count
            } else {
//                tableView.backgroundView = nil
                return movieSearchResult.count
            }
        } else {
//            tableView.backgroundView = nil
            return movies.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie: NSDictionary
        if searchController.active && searchController.searchBar.text != "" {
            movie = movieSearchResult[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        cell.movie=movie
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}


extension MainViewController:UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        movieSearchResult = movies.filter{aMovie in
            return aMovie["title"]!.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
        }
        tableView.reloadData()
    }
    
}
