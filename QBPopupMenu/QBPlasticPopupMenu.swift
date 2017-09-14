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

    func drawLeftSeparatorIn(rect: CGRect, highlighted: Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        context.addRect(rect)
        context.clip()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = {
            var components = [CGFloat](repeating: 0, count: 16)
            if (highlighted) {
                components[0]  = 0.22; components[1]  = 0.47; components[2]  = 0.87; components[3]  = 1;
                components[4]  = 0.12; components[5]  = 0.50; components[6]  = 0.89; components[7]  = 1;
                components[8]  = 0.09; components[9]  = 0.47; components[10] = 0.88; components[11] = 1;
                components[12] = 0.03; components[13] = 0.18; components[14] = 0.74; components[15] = 1;
            } else {
                components[0]  = 0.31; components[1]  = 0.31; components[2]  = 0.31; components[3]  = 1;
                components[4]  = 0.31; components[5]  = 0.31; components[6]  = 0.31; components[7]  = 1;
                components[8]  = 0.24; components[9]  = 0.24; components[10] = 0.24; components[11] = 1;
                components[12] = 0.05; components[13] = 0.05; components[14] = 0.05; components[15] = 1;
            }
            return components
        }()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 4)!
        
        let startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
        let endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        context.restoreGState()
    }
    
    func drawRightSeparatorIn(rect: CGRect, highlighted: Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        context.addRect(rect)
        context.clip()

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let components: [CGFloat] = {
            var components = [CGFloat](repeating: 0, count: 16)
            if (highlighted) {
                components[0]  = 0.22; components[1]  = 0.47; components[2]  = 0.87; components[3]  = 1;
                components[4]  = 0.03; components[5]  = 0.18; components[6]  = 0.72; components[7]  = 1;
                components[8]  = 0.02; components[9]  = 0.15; components[10] = 0.73; components[11] = 1;
                components[12] = 0.03; components[13] = 0.17; components[14] = 0.72; components[15] = 1;
            } else {
                components[0]  = 0.31; components[1]  = 0.31; components[2]  = 0.31; components[3]  = 1;
                components[4]  = 0.06; components[5]  = 0.06; components[6]  = 0.06; components[7]  = 1;
                components[8]  = 0.04; components[9]  = 0.04; components[10] = 0.04; components[11] = 1;
                components[12] = 0;    components[13] = 0;    components[14] = 0;    components[15] = 1;
            }
            return components
        }()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 4)!
        
        let startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y)
        let endPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height)
        
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        context.restoreGState()
    }
    
    
    private func fillPath(context: CGContext, path: CGPath, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    {
        context.saveGState()
        context.addPath(path)
        context.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        context.fillPath()
        context.restoreGState()
    }
    
    override func drawBodyIn(rect: CGRect, firstItem: Bool, lastItem: Bool, highlighted: Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Border
        fillPath(context: context, path: bodyPathIn(rect: rect), red: 0, green: 0, blue: 0, alpha: 1)
        
        // Highlight
        let path = bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 1, width: rect.size.width, height: rect.size.height - 2))
        if highlighted {
            fillPath(context: context, path: path, red: 0.384, green: 0.608, blue: 0.906, alpha: 1.0)
        } else {
            fillPath(context: context, path: path, red: 0.471, green: 0.471, blue: 0.471, alpha: 1.0)
        }

        // Upper body
        context.saveGState()
        context.addPath(bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: rect.size.width, height: rect.size.height / 2 - 2)))
        context.clip()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var components: [CGFloat] = {
            var components = [CGFloat](repeating: 0, count: 8)
            if (highlighted) {
                components[0] = 0.216; components[1] = 0.471; components[2] = 0.871; components[3] = 1;
                components[4] = 0.059; components[5] = 0.353; components[6] = 0.839; components[7] = 1;
            } else {
                components[0] = 0.314; components[1] = 0.314; components[2] = 0.314; components[3] = 1;
                components[4] = 0.165; components[5] = 0.165; components[6] = 0.165; components[7] = 1;
            }
            return components
        }()
        var gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2)!
        
        var startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + 2)
        var endPoint = CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height / 2 - 2)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        context.restoreGState()

        // Lower body
        context.saveGState()
        context.addPath(bodyPathIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2, width: rect.size.width, height: rect.size.height / 2 - 1)))
        context.clip()
        components = {
            var components = [CGFloat](repeating: 0, count: 8)
            if (highlighted) {
                components[0] = 0.047; components[1] = 0.306; components[2] = 0.827; components[3] = 1;
                components[4] = 0.027; components[5] = 0.176; components[6] = 0.737; components[7] = 1;
            } else {
                components[0] = 0.102; components[1] = 0.102; components[2] = 0.102; components[3] = 1;
                components[4] = 0;     components[5] = 0;     components[6] = 0;     components[7] = 1;
            }
            return components
        }()
        gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: nil, count: 2)!
        
        startPoint = CGPoint(x: rect.origin.x, y: rect.origin.y + rect.size.height / 2)
        endPoint = CGPoint(x: rect.origin.x, y:  rect.origin.y + rect.size.height - 1)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        context.restoreGState()
        
        // Draw separator
        if !firstItem {
            drawLeftSeparatorIn(rect: CGRect(x: rect.origin.x, y: rect.origin.y + 2, width: 1, height: rect.size.height - 3), highlighted: highlighted)
        }
        if !lastItem {
            drawRightSeparatorIn(rect: CGRect(x: rect.origin.x + rect.size.width - 1, y: rect.origin.y + 2, width: 1, height: rect.size.height - 3), highlighted: highlighted)
        }
    }
}


