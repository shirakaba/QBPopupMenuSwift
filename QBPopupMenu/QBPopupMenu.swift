//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

protocol QBPopupMenuDelegate: class {
    func popupMenuWillAppear    (menu: QBPopupMenu)
    func popupMenuDidAppear     (menu: QBPopupMenu)
    func popupMenuWillDisappear (menu: QBPopupMenu)
    func popupMenuDidDisappear  (menu: QBPopupMenu)
}

enum QBPopupMenuArrowDirection {
    case up
    case down
    case left
    case right
}

class QBPopupMenu: UIView, QBPopupMenuDrawing {

    struct Config {
        let popupMenuInsets: UIEdgeInsets
        let margin: CGFloat
        let cornerRadius: CGFloat
        let color: UIColor
        let highlightedColor: UIColor
        let arrowSize: CGFloat
        let animationDuration: TimeInterval
        let height: CGFloat
        let pagenatorWidth: CGFloat
        
        static var standard: Config {
            return Config(
                popupMenuInsets:    UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
                margin:             2,
                cornerRadius:       8,
                color:              UIColor.black.withAlphaComponent(0.8),
                highlightedColor:   UIColor.darkGray.withAlphaComponent(0.8),
                arrowSize:          9,
                animationDuration:  0.2,
                height:             36,
                pagenatorWidth:     10 + 10 * 2
            )
        }
    }
    
    struct Item {
        
        let title: String?
        let image: UIImage?
        let action: (()->())?
        
        init(title: String? = nil, image: UIImage? = nil, action: (()->())? = nil) {
            precondition(title != nil || image != nil, "Title or image needs to be set.")
            
            self.title = title
            self.image = image
            self.action = action
        }
    }

    let config:                         Config
    private var itemViews:              [QBPopupMenuItemView]
    private var groupedItemViews:       [[QBPopupMenuItemView]]?
    private var visibleItemViews =      [QBPopupMenuItemView]()
    
    private var targetRect:             CGRect?
    private weak var view:              UIView?
    private(set) var arrowDirection:    QBPopupMenuArrowDirection = .up
    private var page: Int               = 0
    private var arrowPoint =            CGPoint.zero
    private var overlayView:            QBPopupMenuOverlayView?

    weak var  delegate:                 QBPopupMenuDelegate?

    init(config: Config = Config.standard, items: [QBPopupMenu.Item]) {
        self.config = config
        itemViews = [QBPopupMenuItemView]()
        
        super.init(frame: .zero)

        for item in items {
            itemViews.append(QBPopupMenuItemView(popupMenu: self, item: item))
        }

        isOpaque = false
        backgroundColor = UIColor.clear
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }

    func showIn(view: UIView, targetRect: CGRect, animated: Bool) {
        
        var topMenuInset = config.popupMenuInsets.top

        //If iPhone in landscape mode ONLY then menu shoudn't be shown over navigation bar
        if !(UI_USER_INTERFACE_IDIOM() == .pad) && !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            topMenuInset = 2 * config.popupMenuInsets.top
        }

        self.view = view
        self.targetRect = targetRect

        if (targetRect.origin.y - (config.height + config.arrowSize)) >= topMenuInset {
            arrowDirection = .down
        } else if (targetRect.origin.y + targetRect.size.height + (config.height + config.arrowSize)) < (view.bounds.size.height - config.popupMenuInsets.bottom) {
            arrowDirection = .up
        } else {
            let left = targetRect.origin.x - config.popupMenuInsets.left
            let right = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + config.popupMenuInsets.right)

            arrowDirection = (left > right) ? .left : .right
        }

        var maximumWidth: CGFloat = 0
        let minimumWidth: CGFloat = 40

        switch (arrowDirection) {
            case .down, .up:
                maximumWidth = view.bounds.size.width - (config.popupMenuInsets.left + config.popupMenuInsets.right)
                if maximumWidth < minimumWidth {
                    maximumWidth = minimumWidth
                }

            case .left:
                maximumWidth = targetRect.origin.x - config.popupMenuInsets.left

            case .right:
                maximumWidth = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + config.popupMenuInsets.right)
        }

        groupItemViewsWithMaximumWidth(maximumWidth)

        showPage(0)

        // fix fast show/hide popupMenu and show 1+ overlayViews
        overlayView?.removeFromSuperview()

        // Create overlay view
        overlayView = QBPopupMenuOverlayView(frame: view.bounds, popupMenu: self)

        // Delegate
        delegate?.popupMenuWillAppear(menu: self)

        // Show
        if let overlayView = overlayView {
            view.addSubview(overlayView)
        }

        if animated {
            alpha = 0
            overlayView?.addSubview(self)

            UIView.animate(withDuration: config.animationDuration, animations: {
                self.alpha = 1.0
            }, completion: {
                finished in
                self.delegate?.popupMenuDidAppear(menu: self)
            })
        } else {
            overlayView?.addSubview(self)
            delegate?.popupMenuDidAppear(menu: self)
        }
    }
    
    func update(targetRect: CGRect) {
        self.targetRect = targetRect;
    
        updatePopupMenuFrameAndArrowPosition()
        updatePopupMenuImage()
    }
    
    func groupItemViewsWithMaximumWidth(_ maximumWidth: CGFloat) {
        var groupedItemViews = [[QBPopupMenuItemView]]()

        // Create new array
        var itemViews = [QBPopupMenuItemView]()
        var width: CGFloat = 0


        if arrowDirection == .left || arrowDirection == .right {
            width += config.arrowSize
        }

        for itemView in self.itemViews {
            // Clear state
            resetItemViewState(itemView)

            let itemViewSize = itemView.sizeThatFits(.zero)
            let isLastItem = (itemView === self.itemViews.last)

            let sizeToAdd = isLastItem ? itemViewSize.width : (itemViewSize.width + config.pagenatorWidth)

            if itemViews.count > 0 && width + sizeToAdd > maximumWidth {
                groupedItemViews.append(itemViews)

                // Create new array
                itemViews = [QBPopupMenuItemView]()
                width = config.pagenatorWidth
                if arrowDirection == .left || arrowDirection == .right {
                    width += config.arrowSize
                }
            }

            itemViews.append(itemView)
            width += itemViewSize.width
        }

        if (itemViews.count > 0) {
            groupedItemViews.append(itemViews)
        }

        self.groupedItemViews = groupedItemViews
    }
    
    func resetItemViewState(_ itemView: QBPopupMenuItemView)
    {
        // NOTE: Reset properties related to the size of the button before colling sizeThatFits: of item view,
        //       or the size of the view will change from the second time.
        itemView.button.contentEdgeInsets = .zero
        itemView.image = nil
        itemView.highlightedImage = nil
    }
    
    func showPage(_ page: Int) {
        self.page = page
        
        updateVisibleItemViews()
        layoutVisibleItemViews()
        updatePopupMenuFrameAndArrowPosition()
        updatePopupMenuImage()
    }
    
    func showPreviousPage() {
        showPage(page - 1)
    }
    
    func showNextPage() {
        showPage(page + 1)
    }
    
    func dismiss(animated: Bool) {
        delegate?.popupMenuWillDisappear(menu: self)

        if (animated) {
            UIView.animate(withDuration: config.animationDuration,
            animations: {
                self.alpha = 0
            }, completion: { finished in
                self.dismiss(animated: false)
            })
        } else {
            removeFromSuperview()
            overlayView?.removeFromSuperview()
            delegate?.popupMenuDidDisappear(menu: self)
        }
    }
    
    func updateVisibleItemViews() {
        // Remove all visible item views
        while self.visibleItemViews.count > 0 {
            self.visibleItemViews.removeFirst().removeFromSuperview()
        }

        // Add item views
        visibleItemViews = [QBPopupMenuItemView]()
        let numberOfPages = self.groupedItemViews?.count ?? 0

        assert(numberOfPages >= page)

        if numberOfPages > 1 && page != 0 {
            let leftPagenatorView = QBPopupMenuPagenatorView(popupMenu: self, direction: .left) {
                self.showPreviousPage()
            }

            addSubview(leftPagenatorView)
            visibleItemViews.append(leftPagenatorView)
        }

        for itemView in groupedItemViews?[page] ?? [] {
            addSubview(itemView)
            visibleItemViews.append(itemView)
        }

        if page < numberOfPages - 1 {
            let rightPagenatorView = QBPopupMenuPagenatorView(popupMenu: self, direction: .right) {
                self.showNextPage()
            }

            addSubview(rightPagenatorView)
            visibleItemViews.append(rightPagenatorView)
        }
    }
    
    func layoutVisibleItemViews() {
        var height = config.height

        if self.arrowDirection == .down || self.arrowDirection == .up {
            height += config.arrowSize
        }

        var offset: CGFloat = 0
        for i in 0 ..< visibleItemViews.count {
            let itemView = visibleItemViews[i]

            // Clear state
            resetItemViewState(itemView)

            // Set item view insets
            if i == 0 && arrowDirection == .left {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, config.arrowSize, 0, 0)
            } else if i == visibleItemViews.count - 1 && arrowDirection == .right {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, config.arrowSize)
            } else if arrowDirection == .down {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, config.arrowSize, 0)
            } else if arrowDirection == .up {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(config.arrowSize, 0, 0, 0)
            }

            // Set item view frame
            let size = itemView.sizeThatFits(.zero)
            var width = size.width

            if (i == 0 && arrowDirection == .left) || (i == visibleItemViews.count - 1 && arrowDirection == .right) {
                width += config.arrowSize
            }

            itemView.frame = CGRect(x: offset, y: 0, width: width, height: height)

            offset += width
        }
    }
    
    func updatePopupMenuFrameAndArrowPosition() {
        guard
            let itemView = visibleItemViews.last,
            let targetRect = targetRect,
            let view = view
        else {
            return
        }

        // Calculate popup frame
        var popupMenuFrame = CGRect.zero
        let width = itemView.frame.origin.x + itemView.frame.size.width
        let height = itemView.frame.origin.y + itemView.frame.size.height

        switch arrowDirection {
            case .down:
                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y - (height + config.margin), width: width, height: height)

                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - config.popupMenuInsets.right {
                    popupMenuFrame.origin.x = view.frame.size.width - config.popupMenuInsets.right - popupMenuFrame.size.width
                }
                if popupMenuFrame.origin.x < config.popupMenuInsets.left {
                    popupMenuFrame.origin.x = config.popupMenuInsets.left
                }

                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
                arrowPoint = CGPoint(x: max(config.cornerRadius, min(popupMenuFrame.size.width - config.cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: popupMenuFrame.size.height)

            case .up:
                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y + targetRect.size.height + config.margin, width: width, height: height)

                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - config.popupMenuInsets.right {
                    popupMenuFrame.origin.x = view.frame.size.width - config.popupMenuInsets.right - popupMenuFrame.size.width
                }
                if popupMenuFrame.origin.x < config.popupMenuInsets.left {
                    popupMenuFrame.origin.x = config.popupMenuInsets.left
                }

                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
                arrowPoint = CGPoint(x: max(config.cornerRadius, min(popupMenuFrame.size.width - config.cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: 0)

            case .left:
                popupMenuFrame = CGRect(x: targetRect.origin.x + targetRect.size.width + config.margin, y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)

                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - config.popupMenuInsets.bottom {
                    popupMenuFrame.origin.y = view.frame.size.height - config.popupMenuInsets.bottom - popupMenuFrame.size.height
                }
                if popupMenuFrame.origin.y < config.popupMenuInsets.top {
                    popupMenuFrame.origin.y = config.popupMenuInsets.top
                }

                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
                arrowPoint = CGPoint(x: 0, y: max(config.cornerRadius, min(popupMenuFrame.size.height - config.cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))

            case .right:
                popupMenuFrame = CGRect(x: targetRect.origin.x - (width + config.margin), y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)

                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - config.popupMenuInsets.bottom {
                    popupMenuFrame.origin.y = view.frame.size.height - config.popupMenuInsets.bottom - popupMenuFrame.size.height
                }
                if popupMenuFrame.origin.y < config.popupMenuInsets.top {
                    popupMenuFrame.origin.y = config.popupMenuInsets.top
                }

                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
                arrowPoint = CGPoint(x: popupMenuFrame.size.width, y: max(config.cornerRadius, min(popupMenuFrame.size.height - config.cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))
        }

        // Round coordinates
        popupMenuFrame = CGRect(x: round(popupMenuFrame.origin.x), y: round(popupMenuFrame.origin.y), width: round(popupMenuFrame.size.width), height: round(popupMenuFrame.size.height))
        arrowPoint =     CGPoint(x: round(arrowPoint.x), y: round(arrowPoint.y))

        self.frame = popupMenuFrame
    }
    
    func updatePopupMenuImage() {
        guard
            let menuImage = popupMenuImage(highlighted: false),
            let menuHighlightedImage = popupMenuImage(highlighted: true)
        else {
                return
        }

        for i in 0 ..< visibleItemViews.count {
            let itemView = visibleItemViews[i]

            itemView.image = cropImageFrom(image: menuImage, inRect: itemView.frame)
            itemView.highlightedImage = cropImageFrom(image: menuHighlightedImage, inRect: itemView.frame)
        }
    }
    
    private func cropImageFrom(image: UIImage, inRect rect: CGRect) -> UIImage? {
        let scale = UIScreen.main.scale
        let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)

        guard let imageRef = image.cgImage?.cropping(to: scaledRect) else {
            return nil
        }

        return UIImage(cgImage: imageRef, scale:scale, orientation: .up)
    }
    
    func popupMenuImage(highlighted: Bool) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)

        // Draw body
        let y = (arrowDirection == .up) ? config.arrowSize : 0

        for i in 0 ..< visibleItemViews.count {
            let itemView = visibleItemViews[i]
            let frame = itemView.frame

            if i == 0 {
                if visibleItemViews.count == 1 {
                    var headRect = CGRect.zero
                    var bodyRect = CGRect.zero
                    var tailRect = CGRect.zero

                    if arrowDirection == .left {
                        headRect = CGRect(x: config.arrowSize, y: y, width: config.cornerRadius, height: config.height)
                        bodyRect = CGRect(x: config.arrowSize + config.cornerRadius, y: y, width: frame.size.width - (config.arrowSize + config.cornerRadius * 2.0), height: config.height)
                        tailRect = CGRect(x: frame.size.width - config.cornerRadius, y: y, width: config.cornerRadius, height: config.height)
                    } else if arrowDirection == .right {
                        headRect = CGRect(x: 0, y: y, width: config.cornerRadius, height: config.height)
                        bodyRect = CGRect(x: config.cornerRadius, y: y, width: frame.size.width - (config.arrowSize + config.cornerRadius * 2.0), height: config.height)
                        tailRect = CGRect(x: frame.size.width - (config.arrowSize + config.cornerRadius), y: y, width: config.cornerRadius, height: config.height)
                    } else {
                        headRect = CGRect(x: 0, y: y, width: config.cornerRadius, height: config.height)
                        bodyRect = CGRect(x: config.cornerRadius, y: y, width: frame.size.width - config.cornerRadius * 2.0, height: config.height)
                        tailRect = CGRect(x: frame.size.width - config.cornerRadius, y: y, width: config.cornerRadius, height: config.height)
                    }

                    drawHeadIn(rect: headRect, highlighted: highlighted)
                    drawBodyIn(rect: bodyRect, firstItem: true, lastItem: true, highlighted: highlighted)
                    drawTailIn(rect: tailRect, highlighted: highlighted)
                } else {
                    var headRect = CGRect.zero
                    var bodyRect = CGRect.zero

                    if arrowDirection == .left {
                        headRect = CGRect(x: config.arrowSize, y: y, width: config.cornerRadius, height: config.height)
                        bodyRect = CGRect(x: config.arrowSize + config.cornerRadius, y: y, width: frame.size.width - (config.arrowSize + config.cornerRadius), height: config.height)
                    } else {
                        headRect = CGRect(x: 0, y: y, width: config.cornerRadius, height: config.height)
                        bodyRect = CGRect(x: config.cornerRadius, y: y, width: frame.size.width - config.cornerRadius, height: config.height)
                    }

                    drawHeadIn(rect: headRect, highlighted: highlighted)
                    drawBodyIn(rect: bodyRect, firstItem: true, lastItem: false, highlighted: highlighted)
                }
            } else if i == visibleItemViews.count - 1 {
                var bodyRect = CGRect.zero
                var tailRect = CGRect.zero

                if arrowDirection == .right {
                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - (config.cornerRadius + config.arrowSize), height: config.height)
                    tailRect = CGRect(x: frame.origin.x + frame.size.width - (config.cornerRadius + config.arrowSize), y: y, width: config.cornerRadius, height: config.height)
                } else {
                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - config.cornerRadius, height: config.height)
                    tailRect = CGRect(x: frame.origin.x + frame.size.width - config.cornerRadius, y: y, width: config.cornerRadius, height: config.height)
                }

                drawBodyIn(rect: bodyRect,  firstItem: false, lastItem: true, highlighted: highlighted)
                drawTailIn(rect: tailRect, highlighted: highlighted)
            } else {
                // Draw body
                let bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: config.height)
                drawBodyIn(rect: bodyRect, firstItem: false, lastItem: false, highlighted: highlighted)
            }
        }

        // Draw arrow
        drawArrowAt(point: arrowPoint, highlighted: highlighted)

        // Create image from buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
   func drawArrowIn(rect: CGRect, highlighted:Bool)
    {
        fillPath(path: arrowPathIn(rect: rect), color: (highlighted ? config.highlightedColor : config.color))

        // Separator
        if arrowDirection == .down || arrowDirection == .up {
            for itemView in visibleItemViews {
                drawSeparatorIn(rect: CGRect(x: itemView.frame.origin.x + itemView.frame.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
            }
        }
    }
    
    func drawHeadIn(rect: CGRect, highlighted:Bool) {
        fillPath(path: headPathIn(rect: rect, cornerRadius: config.cornerRadius), color: (highlighted ? config.highlightedColor : config.color))
    }
    
    func drawTailIn(rect: CGRect, highlighted:Bool) {
        fillPath(path: tailPathIn(rect: rect, cornerRadius: config.cornerRadius), color: (highlighted ? config.highlightedColor : config.color))
    }

    func drawBodyIn(rect: CGRect, firstItem: Bool, lastItem: Bool, highlighted: Bool) {
        fillPath(path: bodyPathIn(rect: rect), color: (highlighted ? config.highlightedColor : config.color))

        // Separator
        if !lastItem {
            drawSeparatorIn(rect: CGRect(x: rect.origin.x + rect.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
        }
    }

    func drawSeparatorIn(rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }

            // Separator
            context.saveGState()
            context.clear(rect)
            context.restoreGState()
        }
    
    func drawArrowAt(point: CGPoint, highlighted: Bool) {
        var arrowRect = CGRect.zero

        switch arrowDirection {
            case .down:
                arrowRect = CGRect(x: point.x - config.arrowSize + 1.0, y: point.y - config.arrowSize, width: config.arrowSize * 2.0 - 1.0, height: config.arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, config.cornerRadius), frame.size.width - config.cornerRadius - arrowRect.size.width)
            case .up:
                arrowRect = CGRect(x: point.x - config.arrowSize + 1.0, y: 0, width: config.arrowSize * 2.0 - 1.0, height: config.arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, config.cornerRadius), self.frame.size.width - config.cornerRadius - arrowRect.size.width)
            case .left:
                arrowRect = CGRect(x: 0, y: point.y - config.arrowSize + 1.0, width: config.arrowSize, height: config.arrowSize * 2.0 - 1.0)
            case .right:
                arrowRect = CGRect(x: point.x - config.arrowSize, y: point.y - config.arrowSize + 1.0, width: config.arrowSize, height: config.arrowSize * 2.0 - 1.0)
        }

        drawArrowIn(rect: arrowRect, highlighted: highlighted)
    }
}

extension QBPopupMenu {

    func arrowPathIn(rect: CGRect) -> CGPath {
        switch arrowDirection {
            case .down:
                return drawPath([
                    .moveTo(rect.origin.x, rect.origin.y),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height)
                 ])
            case .up:
                return drawPath([
                    .moveTo(rect.origin.x, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y)
                ])
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
        }
    }

    func headPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
                .moveTo(rect.origin.x, rect.origin.y + cornerRadius),
                .arcTo (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                .lineTo(rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
                .arcTo (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius),
         ])
     }
    
    func tailPathIn(rect:CGRect, cornerRadius: CGFloat) -> CGPath {
        return drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }

    func bodyPathIn(rect: CGRect) -> CGPath {
        return drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
     }
}
