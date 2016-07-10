//
//  DetailViewController.swift
//  Flicks
//
//  Created by Huynh Tri Dung on 7/9/16.
//  Copyright © 2016 Huynh Tri Dung. All rights reserved.
//

import UIKit

class DetailMovieViewController: UIViewController {

    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieOverview: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    
    var movie:NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: CGRectGetMaxY(infoView.frame))
        
        if let posterPath = movie["poster_path"] as? String {
            let smallImageURL = "http://image.tmdb.org/t/p/w500"
            let largeImageURL = "http://image.tmdb.org/t/p/w1000"
            
            let smallImageRequest = NSURLRequest(URL: NSURL(string: smallImageURL + posterPath)!)
            let largeImageRequest = NSURLRequest(URL: NSURL(string: largeImageURL + posterPath)!)
            
            moviePoster.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // smallImageResponse will be nil if the smallImage is already available
                    // in cache (might want to do something smarter in that case).
                    self.moviePoster.alpha = 0.0
                    self.moviePoster.image = smallImage;
                    
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        
                        self.moviePoster.alpha = 1.0
                        
                        }, completion: { (sucess) -> Void in
                            
                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                            // per ImageView. This code must be in the completion block.
                            self.moviePoster.setImageWithURLRequest(
                                largeImageRequest,
                                placeholderImage: smallImage,
                                success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                    
                                    self.moviePoster.image = largeImage;
                                },
                                failure: { (request, response, error) -> Void in
                                    // do something for the failure condition of the large image request
                                    // possibly setting the ImageView's image to a default image
                            })
                    })
                },
                failure: { (request, response, error) -> Void in
                    let imgUrl = NSURL(string: largeImageURL + posterPath)
                    self.moviePoster.setImageWithURL(imgUrl!)
            })
        }
        
        
        

        
        movieTitle.text = movie["title"] as? String
        movieOverview.text = movie["overview"] as? String
        movieOverview.sizeToFit()
        
        title = movieTitle.text
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
