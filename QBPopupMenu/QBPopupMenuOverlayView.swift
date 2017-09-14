//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import UIKit

class QBPopupMenuOverlayView: UIView
{

    private(set) weak var popupMenu: QBPopupMenu?
    
    init(frame: CGRect, popupMenu: QBPopupMenu) {
        self.popupMenu = popupMenu
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view === self {
            self.popupMenu?.dismiss(animated: true)
            return nil
        }
        
        return view
    }
}
