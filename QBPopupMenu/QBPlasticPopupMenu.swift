//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import UIKit

class QBPlasticPopupMenuNew : QBPopupMenu
{
    
    func upperHeadPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
            .moveTo (rect.origin.x, rect.origin.y + cornerRadius),
            .arcTo  (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }
    
    func lowerHeadPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
            .arcTo  (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius)
        ])
    }
    
    func upperTailPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
            .arcTo  (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height)
        ])
    }
    
    func lowerTailPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
            .arcTo  (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }

}


