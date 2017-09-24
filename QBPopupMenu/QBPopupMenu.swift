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

class QBPopupMenu: UIView {

    let config:                         Config
    private var itemViews:              [ItemView]
    private var groupedItemViews:       [[ItemView]]?
    private var visibleItemViews =      [ItemView]()
    
    private var targetRect:             CGRect?
    private weak var view:              UIView?
    private(set) var arrowDirection:    ArrowDirection = .up
    private var page: Int               = 0
    private var arrowPoint =            CGPoint.zero
    private var overlay:                Overlay?

    weak var  delegate:                 QBPopupMenuDelegate?

    init(config: Config = Config.standard, items: [QBPopupMenu.Item]) {
        self.config = config
        itemViews = [ItemView]()
        
        super.init(frame: .zero)

        for item in items {
            itemViews.append(ItemView(popupMenu: self, item: item))
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

        switch arrowDirection {
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
        overlay?.removeFromSuperview()

        // Create overlay view
        overlay = Overlay(frame: view.bounds, popupMenu: self)

        // Delegate
        delegate?.popupMenuWillAppear(menu: self)

        // Show
        if let overlay = overlay {
            view.addSubview(overlay)
        }

        if animated {
            alpha = 0
            overlay?.addSubview(self)

            UIView.animate(withDuration: config.animationDuration, animations: {
                self.alpha = 1.0
            }, completion: {
                finished in
                self.delegate?.popupMenuDidAppear(menu: self)
            })
        } else {
            overlay?.addSubview(self)
            delegate?.popupMenuDidAppear(menu: self)
        }
    }
    
    func update(targetRect: CGRect) {
        self.targetRect = targetRect
    
        updatePopupMenuFrameAndArrowPosition()
        updatePopupMenuImage()
    }
    
    func groupItemViewsWithMaximumWidth(_ maximumWidth: CGFloat) {
        var groupedItemViews = [[ItemView]]()

        // Create new array
        var newGroup = [ItemView]()
        var width: CGFloat = 0

        if arrowDirection == .left || arrowDirection == .right {
            width += config.arrowSize
        }

        for itemView in itemViews {
            // Clear state
            resetItemViewState(itemView)

            let itemViewSize = itemView.sizeThatFits(.zero)
            let isLastItem = (itemView === itemViews.last)

            let sizeToAdd = isLastItem ? itemViewSize.width : (itemViewSize.width + config.pagenatorWidth)

            if newGroup.count > 0 && width + sizeToAdd > maximumWidth {
                groupedItemViews.append(newGroup)

                // Create new array
                newGroup = [ItemView]()
                width = config.pagenatorWidth
                if arrowDirection == .left || arrowDirection == .right {
                    width += config.arrowSize
                }
            }

            newGroup.append(itemView)
            width += itemViewSize.width
        }

        if newGroup.count > 0 {
            groupedItemViews.append(newGroup)
        }

        self.groupedItemViews = groupedItemViews
    }
    
    private func resetItemViewState(_ itemView: ItemView)
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

        if animated {
            UIView.animate(withDuration: config.animationDuration,
            animations: {
                self.alpha = 0
            }, completion: { finished in
                self.dismiss(animated: false)
            })
        } else {
            removeFromSuperview()
            overlay?.removeFromSuperview()
            delegate?.popupMenuDidDisappear(menu: self)
        }
    }
    
    func updateVisibleItemViews() {
        // Remove all visible item views
        while visibleItemViews.count > 0 {
            visibleItemViews.removeFirst().removeFromSuperview()
        }

        // Add item views
        visibleItemViews = [ItemView]()
        let numberOfPages = groupedItemViews?.count ?? 0

        assert(numberOfPages >= page)

        if numberOfPages > 1 && page != 0 {
            let leftPagenatorView = PagenatorView(popupMenu: self, direction: .left) {
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
            let rightPagenatorView = PagenatorView(popupMenu: self, direction: .right) {
                self.showNextPage()
            }

            addSubview(rightPagenatorView)
            visibleItemViews.append(rightPagenatorView)
        }
    }
    
    func layoutVisibleItemViews() {
        var height = config.height

        if arrowDirection == .down || arrowDirection == .up {
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

        frame = popupMenuFrame
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
        QBPopupMenu.fillPath(path: arrowPathIn(rect: rect), color: (highlighted ? config.highlightedColor : config.color))

        // Separator
        if arrowDirection == .down || arrowDirection == .up {
            for itemView in visibleItemViews {
                drawSeparatorIn(rect: CGRect(x: itemView.frame.origin.x + itemView.frame.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
            }
        }
    }
    
    func drawHeadIn(rect: CGRect, highlighted:Bool) {
        QBPopupMenu.fillPath(path: headPathIn(rect: rect, cornerRadius: config.cornerRadius), color: (highlighted ? config.highlightedColor : config.color))
    }
    
    func drawTailIn(rect: CGRect, highlighted:Bool) {
        QBPopupMenu.fillPath(path: tailPathIn(rect: rect, cornerRadius: config.cornerRadius), color: (highlighted ? config.highlightedColor : config.color))
    }

    func drawBodyIn(rect: CGRect, firstItem: Bool, lastItem: Bool, highlighted: Bool) {
        QBPopupMenu.fillPath(path: bodyPathIn(rect: rect), color: (highlighted ? config.highlightedColor : config.color))

        // Separator
        if !lastItem {
            drawSeparatorIn(rect: CGRect(x: rect.origin.x + rect.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
        }
    }

    func drawSeparatorIn(rect: CGRect) {
        QBPopupMenu.withCGContext() { context in
            context.clear(rect)
        }
    }
    
    func drawArrowAt(point: CGPoint, highlighted: Bool) {
        var arrowRect = CGRect.zero

        switch arrowDirection {
            case .down:
                arrowRect = CGRect(x: point.x - config.arrowSize + 1.0, y: point.y - config.arrowSize, width: config.arrowSize * 2.0 - 1.0, height: config.arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, config.cornerRadius), frame.size.width - config.cornerRadius - arrowRect.size.width)
            case .up:
                arrowRect = CGRect(x: point.x - config.arrowSize + 1.0, y: 0, width: config.arrowSize * 2.0 - 1.0, height: config.arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, config.cornerRadius), frame.size.width - config.cornerRadius - arrowRect.size.width)
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
                return QBPopupMenu.drawPath([
                    .moveTo(rect.origin.x, rect.origin.y),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height)
                 ])
            case .up:
                return QBPopupMenu.drawPath([
                    .moveTo(rect.origin.x, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y)
                ])
            case .left:
                return QBPopupMenu.drawPath([
                    .moveTo(rect.origin.x + rect.size.width, rect.origin.y),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x, rect.origin.y + rect.size.height / 2.0)
                    ])
            case .right:
                return QBPopupMenu.drawPath([
                    .moveTo(rect.origin.x, rect.origin.y),
                    .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2.0)
                    ])
        }
    }

    func headPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
                .moveTo(rect.origin.x, rect.origin.y + cornerRadius),
                .arcTo (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                .lineTo(rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
                .arcTo (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius),
         ])
     }
    
    func tailPathIn(rect:CGRect, cornerRadius: CGFloat) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }

    func bodyPathIn(rect: CGRect) -> CGPath {
        return QBPopupMenu.drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
     }
}

extension QBPopupMenu {
    
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
        
        init(
            popupMenuInsets: UIEdgeInsets   = Config.standard.popupMenuInsets,
            margin: CGFloat                 = Config.standard.margin,
            cornerRadius: CGFloat           = Config.standard.cornerRadius,
            color: UIColor                  = Config.standard.color,
            highlightedColor: UIColor       = Config.standard.highlightedColor,
            arrowSize: CGFloat              = Config.standard.arrowSize,
            animationDuration: TimeInterval = Config.standard.animationDuration,
            height: CGFloat                 = Config.standard.height,
            pagenatorWidth: CGFloat         = Config.standard.pagenatorWidth
            ) {
            self.popupMenuInsets = popupMenuInsets
            self.margin = margin
            self.cornerRadius = cornerRadius
            self.color = color
            self.highlightedColor = highlightedColor
            self.arrowSize = arrowSize
            self.animationDuration = animationDuration
            self.height = height
            self.pagenatorWidth = pagenatorWidth
        }
        
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
}

extension QBPopupMenu {
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
}

extension QBPopupMenu {
    
    private class Overlay: UIView
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
                popupMenu?.dismiss(animated: true)
                return nil
            }
            
            return view
        }
    }
}

extension QBPopupMenu {
    
    private class ItemView: UIView {
        
        weak var popupMenu: QBPopupMenu?
        let button: UIButton
        let item: QBPopupMenu.Item?
        
        init(popupMenu: QBPopupMenu, item: QBPopupMenu.Item? = nil) {
            
            self.popupMenu = popupMenu
            self.item = item
            self.button = UIButton(type: .custom)
            
            super.init(frame: .zero)
            
            isOpaque = false
            backgroundColor = UIColor.clear
            clipsToBounds = true
            
            button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
            button.frame = bounds
            button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            button.contentMode = .scaleAspectFit
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.imageView?.contentMode = .scaleAspectFit
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitleColor(UIColor.white, for: .highlighted)
            
            button.setTitle(item?.title, for: .normal)
            button.setImage(item?.image, for: .normal)
            button.setImage(item?.image, for: .highlighted)
            
            if item?.title != nil && item?.image != nil {
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
                button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
            } else {
                button.titleEdgeInsets = .zero
                button.imageEdgeInsets = .zero
            }
            
            addSubview(button)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) can not be used.")
        }
        
        @objc func performAction() {
            item?.action?()
            popupMenu?.dismiss(animated: true)
        }
        
        var image: UIImage? {
            get {
                return button.backgroundImage(for: .normal)
            }
            
            set(newImage) {
                button.setBackgroundImage(newImage, for: .normal)
            }
        }
        
        var highlightedImage: UIImage? {
            get {
                return button.backgroundImage(for: .highlighted)
            }
            
            set(newImage) {
                button.setBackgroundImage(newImage, for: .highlighted)
            }
        }
        
        override func sizeToFit() {
            frame.size = sizeThatFits(.zero)
        }
        
        override func sizeThatFits(_ size: CGSize) -> CGSize {
            var buttonSize = button.sizeThatFits(.zero)
            buttonSize.width += 10 * 2
            
            return buttonSize
        }
    }
}

extension QBPopupMenu {
    
    private class PagenatorView: ItemView {
        
        let action: (()->())?
        
        init(popupMenu: QBPopupMenu, direction: ArrowDirection, action: (()->())? = nil)
        {
            self.action = action
            
            super.init(popupMenu: popupMenu)
            
            let image = arrowImage(arrowDirection: direction)
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
            buttonSize.width = popupMenu?.config.pagenatorWidth ?? 0
            
            return buttonSize
        }
        
        private func arrowImage(arrowDirection: ArrowDirection) -> UIImage? {
            
            let size = CGSize(width: 10, height: 10)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            
            fillPath(path: arrowPathIn(rect: rect, arrowDirection: arrowDirection), color: UIColor.white)
            
            // Create image from buffer
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        }
        
        private func arrowPathIn(rect: CGRect, arrowDirection: ArrowDirection) -> CGPath {
            
            switch arrowDirection {
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
    
}

extension QBPopupMenu {

    enum DrawingSegment {
        case moveTo(CGFloat, CGFloat)
        case lineTo(CGFloat, CGFloat)
        case arcTo(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat)
    }

    static func drawPath(_ segments: [DrawingSegment]) -> CGPath {
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
    
    static func drawRect(_ rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        path.addRect(rect)
        return path
    }
    
    static func fillPath(path: CGPath, color: UIColor) {
        withCGContext() { context in
            context.addPath(path)
            context.setFillColor(color.cgColor)
            context.fillPath()
        }
    }
    
    static func withCGContext(body: ((CGContext) -> ())) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.saveGState()
        body(context)
        context.restoreGState()
    }
    
    static func fillGradient(path: CGPath, startPoint: CGPoint, endPoint: CGPoint, gradienComponents: [CGFloat], gradientLocations: [CGFloat]? = nil) {
        precondition((gradienComponents.count % 4) == 0, "Gradient componets is set of RGBA values and must be dividable by 4.")
        precondition((gradientLocations.flatMap({ $0.count * 4 }) ?? gradienComponents.count) == gradienComponents.count, "Invalid number of gradient locations. Needs to match gradientComponents count.")
        
        withCGContext() { context in
            context.addPath(path)
            context.clip()
            
            guard let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: gradienComponents, locations: gradientLocations, count: gradienComponents.count / 4) else {
                preconditionFailure("Gradient not created!")
            }
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: .drawsAfterEndLocation)
        }
    }
}

extension QBPopupMenu {
    
    enum ArrowDirection {
        case up
        case down
        case left
        case right
    }
}
