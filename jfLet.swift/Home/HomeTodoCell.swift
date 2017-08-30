//
//  HomeTodoCell.swift
//  jfLet.swift
//
//  Created by 张炯枫 on 2017/5/29.
//  Copyright © 2017年 fisland. All rights reserved.
//

import UIKit
import UIKit
import BEMCheckBox

protocol HomeTodoCellDelegate {
    func didFinishedCheck(cell:HomeTodoCell)
}

class HomeTodoCell: UITableViewCell,BEMCheckBoxDelegate {

    @IBOutlet weak var checkBox: BEMCheckBox!
    @IBOutlet weak var mainTitle: UILabel!

    var delegate : HomeTodoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        checkBox.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        
    }
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        if let del = delegate{
            del.didFinishedCheck(cell: self)
        }
    }

}
