//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import UIKit

/**
 Extends QBPopupMenu and modifies menu appearance to be 3D plastic like
 */
class QBPlasticPopupMenu : QBPopupMenu
{
    
    func upperHeadPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo (rect.origin.x, rect.origin.y + cornerRadius),
            .arcTo  (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }
    
    func lowerHeadPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
            .arcTo  (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius)
        ])
    }
    
    func upperTailPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
            .arcTo  (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height)
        ])
    }
    
    func lowerTailPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo (rect.origin.x, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
            .arcTo  (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
            .lineTo (rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }

    func drawLeftSeparatorIn(rect: CGRect, highlighted: Bool) {
        QBPopupMenu.fillGradient(
            path: QBPopupMenu.drawRect(rect),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y),
            endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
            gradienComponents: highlighted ? [0.22, 0.47, 0.87, 1, 0.12, 0.50, 0.89, 1, 0.09, 0.47, 0.88, 1, 0.03, 0.18, 0.74, 1] : [0.31, 0.31, 0.31, 1, 0.31, 0.31, 0.31, 1, 0.24, 0.24, 0.24, 1, 0.05, 0.05, 0.05, 1]
        )
    }
    
    func drawRightSeparatorIn(rect: CGRect, highlighted: Bool) {
        QBPopupMenu.fillGradient(
            path: QBPopupMenu.drawRect(rect),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y),
            endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
            gradienComponents: highlighted ? [0.22, 0.47, 0.87, 1, 0.03, 0.18, 0.72, 1, 0.02, 0.15, 0.73, 1, 0.03, 0.17, 0.72, 1] : [0.31, 0.31, 0.31, 1, 0.06, 0.06, 0.06, 1, 0.04, 0.04, 0.04, 1, 0, 0, 0, 1]
        )
    }
    
    override func drawBodyIn(rect: CGRect, firstItem: Bool, lastItem: Bool, highlighted: Bool) {
        // Border
        QBPopupMenu.fillPath(path: bodyPathIn(rect: rect), color: UIColor(red: 0, green: 0, blue: 0, alpha: 1))
        
        // Highlight
        QBPopupMenu.fillPath(
            path: bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 1, width: rect.size.width, height: rect.size.height - 2)),
            color: highlighted ? UIColor(red: 0.384, green: 0.608, blue: 0.906, alpha: 1.0) : UIColor(red: 0.471, green: 0.471, blue: 0.471, alpha: 1.0)
        )

        // Upper body
        QBPopupMenu.fillGradient(
            path: bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: rect.size.width, height: rect.size.height / 2 - 2)),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + 2),
            endPoint: CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height / 2 - 2),
            gradienComponents: highlighted ? [0.216, 0.471, 0.871, 1, 0.059, 0.353, 0.839, 1] : [0.314, 0.314, 0.314, 1, 0.165, 0.165, 0.165, 1]
        )

        // Lower body
        QBPopupMenu.fillGradient(
            path: bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2, width: rect.size.width, height: rect.size.height / 2 - 1)),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2),
            endPoint: CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height - 1),
            gradienComponents: highlighted ? [0.047, 0.306, 0.827, 1, 0.027, 0.176, 0.737, 1] : [0.102, 0.102, 0.102, 1, 0, 0, 0, 1]
        )
        
        // Draw separator
        if !firstItem {
            drawLeftSeparatorIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: 1, height: rect.size.height - 3), highlighted: highlighted)
        }
        if !lastItem {
            drawRightSeparatorIn(rect: CGRect(x: rect.origin.x + rect.size.width - 1, y: rect.origin.y + 2, width: 1, height: rect.size.height - 3), highlighted: highlighted)
        }
    }
    
    override func drawTailIn(rect: CGRect, highlighted: Bool) {
        // Border
        QBPopupMenu.fillPath(path: tailPathIn(rect: rect, cornerRadius: config.cornerRadius), color: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))
    
        // Highlight
        QBPopupMenu.fillPath(
            path: tailPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 1, width: rect.size.width - 1, height: rect.size.height - 2), cornerRadius: config.cornerRadius - 1),
            color: highlighted ? UIColor(red: 0.384, green: 0.608, blue: 0.906, alpha: 1.0) : UIColor(red: 0.471, green: 0.471, blue: 0.471, alpha: 1.0)
        )
        
        // Upper body
        QBPopupMenu.fillGradient(
            path: upperTailPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: rect.size.width - 1, height: rect.size.height / 2 - 2), cornerRadius: config.cornerRadius - 1),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + 2),
            endPoint: CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height / 2 - 2),
            gradienComponents: highlighted ? [0.216, 0.471, 0.871, 1, 0.059, 0.353, 0.839, 1] : [0.314, 0.314, 0.314, 1, 0.165, 0.165, 0.165, 1]
        )
    
        // Lower body
        QBPopupMenu.fillGradient(
            path: lowerTailPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2, width: rect.size.width - 1, height: rect.size.height / 2 - 1), cornerRadius: config.cornerRadius - 1),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2),
            endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - 1),
            gradienComponents: highlighted ? [0.047, 0.306, 0.827, 1, 0.027, 0.176, 0.737, 1] : [0.102, 0.102, 0.102, 1, 0, 0, 0, 1]
        )
    }
    
    override func drawHeadIn(rect: CGRect, highlighted: Bool) {
        // Border
        QBPopupMenu.fillPath(path: headPathIn(rect: rect, cornerRadius: config.cornerRadius), color: UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))

        // Highlight
        QBPopupMenu.fillPath(
            path: headPathIn(rect: CGRect(x: rect.origin.x + 1, y: rect.origin.y + 1, width: rect.size.width - 1, height: rect.size.height - 2), cornerRadius: config.cornerRadius - 1),
            color: highlighted ? UIColor(red: 0.384, green:  0.608, blue: 0.906, alpha: 1.0) : UIColor(red: 0.471, green: 0.471, blue: 0.471, alpha: 1.0)
        )

        // Upper head
        QBPopupMenu.fillGradient(
            path: upperHeadPathIn(rect: CGRect(x: rect.origin.x + 1, y: rect.origin.y + 2, width: rect.size.width - 1, height: rect.size.height / 2 - 2), cornerRadius: config.cornerRadius - 1),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + 2),
            endPoint: CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height / 2 - 2),
            gradienComponents: highlighted ? [0.216, 0.471, 0.871, 1, 0.059, 0.353, 0.839, 1] : [0.314, 0.314, 0.314, 1, 0.165, 0.165, 0.165, 1]
        )
    
        // Lower head
        QBPopupMenu.fillGradient(
            path: lowerHeadPathIn(rect: CGRect(x: rect.origin.x + 1, y: rect.origin.y + rect.size.height / 2, width: rect.size.width - 1, height: rect.size.height / 2 - 1), cornerRadius: config.cornerRadius - 1),
            startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2),
            endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height - 1),
            gradienComponents: highlighted ? [0.047, 0.306, 0.827, 1, 0.027, 0.176, 0.737, 1] : [0.102, 0.102, 0.102, 1, 0, 0, 0, 1]
        )
    }
    
    override func drawArrowIn(rect: CGRect, highlighted: Bool) {
        // Border
        var arrowRect: CGRect = {
            switch arrowDirection {
                case .down:
                    return CGRect(x: rect.origin.x, y: rect.origin.y - 0.6, width: rect.size.width, height: rect.size.height)
                case .up:
                    return CGRect(x: rect.origin.x, y: rect.origin.y + 0.6, width: rect.size.width, height: rect.size.height)
                case .left:
                    return CGRect(x: rect.origin.x + 0.6, y: rect.origin.y - 0.5, width: rect.size.width, height: rect.size.height)
                case .right:
                    return CGRect(x: rect.origin.x - 0.6, y: rect.origin.y - 0.5, width: rect.size.width, height: rect.size.height)
            }
        }()
        QBPopupMenu.fillPath(path: arrowPathIn(rect: arrowRect), color: UIColor(red: 0, green: 0, blue: 0, alpha: 1))

    
        // Highlight
        arrowRect = {
            switch arrowDirection {
                case .up:
                    return CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: rect.size.width, height: rect.size.height)
                case .left:
                    return CGRect(x: rect.origin.x + 2, y: rect.origin.y - 0.5 + 1, width: rect.size.width - 1, height: rect.size.height - 2)
                case .right:
                    return CGRect(x: rect.origin.x - 1, y: rect.origin.y - 0.5 + 1, width: rect.size.width - 1, height: rect.size.height - 2)
                case .down:
                    return CGRect.zero
            }
        }()

        QBPopupMenu.fillPath(
            path: arrowPathIn(rect: arrowRect),
            color: highlighted ? UIColor(red: 0.384, green: 0.608, blue: 0.906, alpha: 1) : UIColor(red: 0.471, green: 0.471, blue: 0.471, alpha: 1)
        )
        
        // Body
        switch arrowDirection {
            case .down:
                if highlighted {
                    QBPopupMenu.fillGradient(
                        path: arrowPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y - 2, width: rect.size.width, height: rect.size.height)),
                        startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y - 2),
                        endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
                        gradienComponents: [0.027, 0.169, 0.733, 1, 0.020, 0.114, 0.675, 1]
                    )
                }

            case .up:
                QBPopupMenu.fillGradient(
                    path: arrowPathIn(rect: CGRect(x: rect.origin.x + 1.4, y: rect.origin.y + 2 + 1.4, width: rect.size.width - 2.8, height: rect.size.height - 1.4)),
                    startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + 2),
                    endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
                    gradienComponents: highlighted ? [0.290, 0.580, 1.000, 1, 0.216, 0.471, 0.871, 1] : [0.401, 0.401, 0.401, 1, 0.314, 0.314, 0.314, 1]
                )
                
            case .left:
                QBPopupMenu.fillGradient(
                    path: arrowPathIn(rect: CGRect(x: rect.origin.x + 2, y: rect.origin.y - 0.5 + 2, width: rect.size.width - 1, height: rect.size.height - 2)),
                    startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y - 1),
                    endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
                    gradienComponents: highlighted ? [0.082, 0.376, 0.859, 1, 0.004, 0.333, 0.851, 1, 0.000, 0.282, 0.839, 1, 0.000, 0.216, 0.796, 1] : [0.216, 0.216, 0.216, 1, 0.165, 0.165, 0.165, 1, 0.102, 0.102, 0.102, 1, 0.051, 0.051, 0.051, 1],
                    gradientLocations: [0.0, 0.5, 0.5, 1.0]
                )
                
            case .right:
                QBPopupMenu.fillGradient(
                    path: arrowPathIn(rect: CGRect(x: rect.origin.x - 1, y: rect.origin.y - 0.5 + 2, width: rect.size.width - 1, height: rect.size.height - 2)),
                    startPoint: CGPoint(x: rect.origin.x, y: rect.origin.y - 1),
                    endPoint: CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height),
                    gradienComponents: highlighted ? [0.082, 0.376, 0.859, 1, 0.004, 0.333, 0.851, 1, 0.000, 0.282, 0.839, 1, 0.000, 0.216, 0.796, 1] : [0.216, 0.216, 0.216, 1, 0.165, 0.165, 0.165, 1, 0.102, 0.102, 0.102, 1, 0.051, 0.051, 0.051, 1],
                    gradientLocations: [0.0, 0.5, 0.5, 1.0]
                )
        }
    }
}


