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

}
