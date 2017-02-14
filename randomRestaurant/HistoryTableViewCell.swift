//
//  HistoryTableViewCell.swift
//  randomRestaurant
//
//  Created by Zhe Cui on 9/20/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var favoriteButton: HistoryCellButton!

    fileprivate let emptyStar = UIImage(named: "emptyStar")
    fileprivate let filledStar = UIImage(named: "filledStar")
    
    //var restaurant: Restaurant?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favoriteButton.setImage(emptyStar, for: .normal)
        favoriteButton.setImage(filledStar, for: .selected)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
