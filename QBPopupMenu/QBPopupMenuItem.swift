//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

@objc class QBPopupMenuItem: NSObject {

    let title: String?
    let image: UIImage?
    let action: (()->())?
    
    @objc init(title: String?, image: UIImage?, action: (()->())?) {
        precondition(title != nil || image != nil, "Title or image needs to be set.")
        
        self.title = title
        self.image = image
        self.action = action

        super.init()
    }
}
