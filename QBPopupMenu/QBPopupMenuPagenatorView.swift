//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

//TODO: move to different place
@objc enum QBPopupMenuArrowDirection: Int {
    case auto = 0
    case up
    case down
    case left
    case right
}

@objc class QBPopupMenuPagenatorView: QBPopupMenuItemView, QBPopupMenuDrawing {

    @objc static let pagenatorWidth = CGFloat(10 + 10 * 2)
    
    let action: (()->())?

    @objc init(direction: QBPopupMenuArrowDirection, action: (()->())?)
    {
        self.action = action
        super.init(item: nil, popupMenu: nil)
        
        let image = arrowImage(direction: direction)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .highlighted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }
    
    override func performAction() {
        action?()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var buttonSize = button.sizeThatFits(.zero)
        buttonSize.width = QBPopupMenuPagenatorView.pagenatorWidth
        
        return buttonSize
    }
    
    private func arrowImage(direction: QBPopupMenuArrowDirection) -> UIImage? {
        
        let size = CGSize(width: 10, height: 10)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        context.saveGState()

        context.addPath(arrowPathIn(rect: rect, direction:direction))
        context.setFillColor(UIColor.white.cgColor)
        context.fillPath()
        
        context.restoreGState()
        
        // Create image from buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
            
        return image
    }
    
    private func arrowPathIn(rect: CGRect, direction: QBPopupMenuArrowDirection) -> CGPath {
        
        switch (direction) {
        case .left:
            return drawPath([
                .moveTo(rect.origin.x + rect.size.width, rect.origin.y),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                .lineTo(rect.origin.x, rect.origin.y + rect.size.height / 2.0)
            ])

        case .right:
            return drawPath([
                .moveTo(rect.origin.x, rect.origin.y),
                .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2.0)
             ])

        default:
            assertionFailure( "Pagenator arrow direction can only be left or right.")
            return CGMutablePath()
        }
    }

}
