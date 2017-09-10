//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

/**
 Simplifying drawing primitives
 */
enum QBPopupMenuDrawingSegment {
    case moveTo(CGFloat, CGFloat)
    case lineTo(CGFloat, CGFloat)
    case arcTo(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
}

protocol QBPopupMenuDrawing {
    func drawPath(_ segments: [QBPopupMenuDrawingSegment]) -> CGPath
}

extension QBPopupMenuDrawing {
    
    func drawPath(_ segments: [QBPopupMenuDrawingSegment]) -> CGPath {
        let path = CGMutablePath()
        
        for segment in segments {
            switch segment {
            case .moveTo(let x, let y):
                path.move(to: CGPoint(x: x, y: y))
            case .lineTo(let x, let y):
                path.addLine(to: CGPoint(x: x, y: y))
            case .arcTo(let x1, let y1, let x2, let y2, let radius):
                path.addArc(tangent1End: CGPoint(x: x1, y: y1), tangent2End: CGPoint(x: x2, y: y2), radius: radius)
            }
        }
        
        path.closeSubpath()
        return path
    }
}
