//
//  MovieTableViewCell.swift
//  Flicks
//
//  Created by Huynh Tri Dung on 7/9/16.
//  Copyright © 2016 Huynh Tri Dung. All rights reserved.
//

import UIKit

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var movieThumbnail: UIImageView!
    @IBOutlet weak var movieOverview: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieThumbnail.layer.cornerRadius = 4.0
        movieThumbnail.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setDataForCell(movie:NSDictionary) {
        if let posterPath = movie["poster_path"] as? String {
            let baseUrl = "http://image.tmdb.org/t/p/w500"
            let imageRequest = NSURLRequest(URL: NSURL(string: baseUrl + posterPath)!)
            
            movieThumbnail.setImageWithURLRequest(
                imageRequest, placeholderImage: nil, success: { (imgUrl, imageResponse, image) in
                    if imageResponse != nil {
    //                    print("Image was NOT cached, fade in image")
                        self.movieThumbnail.alpha = 0.0
                        self.movieThumbnail.image = image
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.movieThumbnail.alpha = 1.0
                        })
                    } else {
    //                    print("Image was cached so just update the image")
                        self.movieThumbnail.image = image
                    }
                }, failure: { (imageRequest, imageResponse, eror) in
                    let imgUrl = NSURL(string: baseUrl + posterPath)
                    self.movieThumbnail.setImageWithURL(imgUrl!)
            })
        }
        movieTitle.text =   movie["title"] as? String
        movieOverview.text = movie["overview"] as? String
    }

}
