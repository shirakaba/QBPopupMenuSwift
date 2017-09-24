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

protocol QBPopupMenuDrawing {}

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
    
    func fillPath(path: CGPath, color: UIColor) {
        withCGContext() { context in
            context.addPath(path)
            context.setFillColor(color.cgColor)
            context.fillPath()
        }
    }
    
    func withCGContext(body: ((CGContext) -> ())) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        body(context)
        context.restoreGState()
    }
    
    func fillGradient(path: CGPath, startPoint: CGPoint, endPoint: CGPoint, gradienComponents: [CGFloat], gradientLocations: [CGFloat]? = nil) {
        withCGContext() { context in
            context.addPath(path)
            context.clip()
            if let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: gradienComponents, locations: gradientLocations, count: gradientLocations?.count ?? 0) {
               
                context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
            }
        }
    }
}
