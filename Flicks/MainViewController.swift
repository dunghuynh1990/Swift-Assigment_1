//
//  MainViewController.swift
//  Flicks
//
//  Created by Huynh Tri Dung on 7/9/16.
//  Copyright © 2016 Huynh Tri Dung. All rights reserved.
//  TODO: Redesign the UI
//  TODO: Make swipe to hide navigation bar on Main. disable on Detail view
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
        
        //set up navigation
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.translucent = false
        navigationController?.tabBarController?.tabBar.barTintColor = UIColor.darkTextColor()
        navigationController?.tabBarController?.tabBar.tintColor = UIColor.whiteColor()
        navigationItem.titleView = searchController.searchBar
        
        //set up search controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Find your favorite movies..."
        searchController.searchBar.barStyle = UIBarStyle.Black
        definesPresentationContext = false
        
        //set up refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.backgroundColor = UIColor.darkTextColor()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // other set up
        lblNetworkErorr.hidden = true
        tableView.tableFooterView = UIView()
        (UIBarButtonItem.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self])).tintColor = UIColor.whiteColor()
        
        requestData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.searchBar.resignFirstResponder()
    }
    
    //TODO: should be delete
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(API_KEY)")
        let request = NSURLRequest(URL: url!)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        self.view.endEditing(true)
        if reachability.isReachable() || reachability.isReachableViaWiFi() || reachability.isReachableViaWWAN(){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {
                (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        self.lblNetworkErorr.hidden = true
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        self.movies = (responseDictionary["results"] as! [NSDictionary])
                        
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "MMM d, h:mm a"
                        let refreshInfo = "Last update: \(dateFormatter.stringFromDate(NSDate()))"
                        refreshControl.attributedTitle = NSAttributedString(string: refreshInfo,
                            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
                        self.tableView.reloadData()
                        refreshControl.endRefreshing()
                        }
                    }
            });
            task.resume()
        }
        else {
            self.lblNetworkErorr.hidden = false
            refreshControl.endRefreshing()
        }
    }
    
    func requestData() {
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            let noDataLabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.frame.size.height/2))
            noDataLabel.textAlignment = NSTextAlignment.Center
            noDataLabel.textColor = UIColor.whiteColor()
            noDataLabel.font.fontWithSize(40)
            noDataLabel.text = ""
            if movieSearchResult.count < 1 {
                noDataLabel.text = "No Results"
                tableView.backgroundView = noDataLabel
                //return movieSearchResult.count
            } else {
                tableView.backgroundView = nil
                //return movieSearchResult.count
            }
            return movieSearchResult.count
        } else {
            tableView.backgroundView = nil
            return movies.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieTableViewCell
        let movie: NSDictionary
        cell.backgroundColor = UIColor.clearColor()
        if searchController.active && searchController.searchBar.text != "" {
            movie = movieSearchResult[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
    
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
            
            cell.movieThumbnail.setImageWithURLRequest(
                imageRequest, placeholderImage: nil, success: { (imgUrl, imageResponse, image) in
                    if imageResponse != nil {
    //                    print("Image was NOT cached, fade in image")
                        cell.movieThumbnail.alpha = 0.0
                        cell.movieThumbnail.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.movieThumbnail.alpha = 1.0
                        })
                    } else {
    //                    print("Image was cached so just update the image")
                        cell.movieThumbnail.image = image
                    }
                }, failure: { (imageRequest, imageResponse, eror) in
                    let imgUrl = NSURL(string: baseUrl + posterPath)
                    cell.movieThumbnail.setImageWithURL(imgUrl!)
            })
        }
        cell.movieTitle.text =   movie["title"] as? String
        cell.movieOverview.text = movie["overview"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: - UISearchResultsUpdating
extension MainViewController:UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        movieSearchResult = movies.filter{aMovie in
            return aMovie["title"]!.lowercaseString.containsString(searchController.searchBar.text!.lowercaseString)
        }
        tableView.reloadData()
    }
}
