//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import UIKit

public struct QBPopupMenuItem {

    public let title: String?
    public let image: UIImage?
    public let action: (()->())?
    
    public init(title: String? = nil, image: UIImage? = nil, action: (()->())? = nil) {
        precondition(title != nil || image != nil, "Title or image needs to be set.")
        
        self.title = title
        self.image = image
        self.action = action
    }
}
