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

@objc class QBPopupMenu: UIView, QBPopupMenuDrawing {

    private(set) var itemViews: [QBPopupMenuItemView]!
    var groupedItemViews: [[QBPopupMenuItemView]]?
    var visibleItemViews = [QBPopupMenuItemView]()
    
    var popupMenuInsets: UIEdgeInsets            = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var margin: CGFloat                          = 2
    var cornerRadius: CGFloat                    = 8
    var color: UIColor                           = UIColor.black.withAlphaComponent(0.8)
    @objc var highlightedColor: UIColor                = UIColor.darkGray.withAlphaComponent(0.8)
    var arrowSize: CGFloat                       = 9
    var popupMenuAnimationDuration: TimeInterval = 0.2
    var height: CGFloat                          = 36

    
    private var targetRect: CGRect?
    private weak var view: UIView?
    private var arrowDirection: QBPopupMenuArrowDirection = .up
    private var page: Int                                 = 0
    private var arrowPoint = CGPoint.zero
    private var overlayView: QBPopupMenuOverlayView?

    weak var  delegate: QBPopupMenuDelegate?

    @objc init(items: [QBPopupMenuItem]) {
        super.init(frame: .zero)

        itemViews = [QBPopupMenuItemView]()

        for item in items {
            itemViews.append(QBPopupMenuItemView(item: item, popupMenu: self))
        }

        isOpaque = false
        backgroundColor = UIColor.clear
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }

    @objc func showIn(view: UIView, targetRect: CGRect, animated: Bool) {
        
        var topMenuInset = self.popupMenuInsets.top

        //If iPhone in landscape mode ONLY then menu shoudn't be shown over navigation bar
        if !(UI_USER_INTERFACE_IDIOM() == .pad) && !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            topMenuInset = 2*self.popupMenuInsets.top
        }

        self.view = view
        self.targetRect = targetRect

        if (targetRect.origin.y - (self.height + self.arrowSize)) >= topMenuInset {
            arrowDirection = .down
        } else if (targetRect.origin.y + targetRect.size.height + (self.height + self.arrowSize)) < (view.bounds.size.height - self.popupMenuInsets.bottom) {
            arrowDirection = .up
        } else {
            let left = targetRect.origin.x - self.popupMenuInsets.left
            let right = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + self.popupMenuInsets.right)

            arrowDirection = (left > right) ? .left : .right
        }

        var maximumWidth: CGFloat = 0
        let minimumWidth: CGFloat = 40

        switch (arrowDirection) {
            case .down, .up:
                maximumWidth = view.bounds.size.width - (self.popupMenuInsets.left + self.popupMenuInsets.right)
                if maximumWidth < minimumWidth {
                    maximumWidth = minimumWidth
                }

            case .left:
                maximumWidth = targetRect.origin.x - self.popupMenuInsets.left

            case .right:
                maximumWidth = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + self.popupMenuInsets.right)
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

            UIView.animate(withDuration: popupMenuAnimationDuration, animations: {
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

        let pagenatorWidth = QBPopupMenuPagenatorView.pagenatorWidth

        // Create new array
        var itemViews = [QBPopupMenuItemView]()
        var width: CGFloat = 0


        if self.arrowDirection == .left || self.arrowDirection == .right {
            width += self.arrowSize
        }

        for itemView in self.itemViews {
            // Clear state
            resetItemViewState(itemView)

            let itemViewSize = itemView.sizeThatFits(.zero)
            let isLastItem = (itemView === self.itemViews.last)

            let sizeToAdd = isLastItem ? itemViewSize.width : (itemViewSize.width + pagenatorWidth)

            if itemViews.count > 0 && width + sizeToAdd > maximumWidth {
                groupedItemViews.append(itemViews)

                // Create new array
                itemViews = [QBPopupMenuItemView]()
                width = pagenatorWidth
                if self.arrowDirection == .left || self.arrowDirection == .right {
                    width += self.arrowSize
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
            UIView.animate(withDuration: popupMenuAnimationDuration,
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
    
    private func updateVisibleItemViews() {
        // Remove all visible item views
        while self.visibleItemViews.count > 0 {
            self.visibleItemViews.removeFirst().removeFromSuperview()
        }

        // Add item views
        visibleItemViews = [QBPopupMenuItemView]()
        let numberOfPages = self.groupedItemViews?.count ?? 0

        assert(numberOfPages >= page)

        if numberOfPages > 1 && page != 0 {
            let leftPagenatorView = QBPopupMenuPagenatorView(direction: .left) {
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
            let rightPagenatorView = QBPopupMenuPagenatorView(direction: .right) {
                self.showNextPage()
            }

            addSubview(rightPagenatorView)
            visibleItemViews.append(rightPagenatorView)
        }
    }
    
    private func layoutVisibleItemViews() {
        var height = self.height

        if self.arrowDirection == .down || self.arrowDirection == .up {
            height += self.arrowSize
        }

        var offset: CGFloat = 0
        for i in 0 ..< visibleItemViews.count {
            let itemView = visibleItemViews[i]

            // Clear state
            resetItemViewState(itemView)

            // Set item view insets
            if i == 0 && arrowDirection == .left {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, arrowSize, 0, 0)
            } else if i == visibleItemViews.count - 1 && arrowDirection == .right {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, arrowSize)
            } else if arrowDirection == .down {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, arrowSize, 0)
            } else if arrowDirection == .up {
                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(arrowSize, 0, 0, 0)
            }

            // Set item view frame
            let size = itemView.sizeThatFits(.zero)
            var width = size.width

            if (i == 0 && arrowDirection == .left) || (i == visibleItemViews.count - 1 && arrowDirection == .right) {
                width += arrowSize
            }

            itemView.frame = CGRect(x: offset, y: 0, width: width, height: height)

            offset += width
        }
    }
    
    private func updatePopupMenuFrameAndArrowPosition() {
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
                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y - (height + margin), width: width, height: height)

                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - popupMenuInsets.right {
                    popupMenuFrame.origin.x = view.frame.size.width - popupMenuInsets.right - popupMenuFrame.size.width
                }
                if popupMenuFrame.origin.x < popupMenuInsets.left {
                    popupMenuFrame.origin.x = popupMenuInsets.left
                }

                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
                arrowPoint = CGPoint(x: max(cornerRadius, min(popupMenuFrame.size.width - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: popupMenuFrame.size.height)

            case .up:
                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y + targetRect.size.height + margin, width: width, height: height)

                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - popupMenuInsets.right {
                    popupMenuFrame.origin.x = view.frame.size.width - popupMenuInsets.right - popupMenuFrame.size.width
                }
                if popupMenuFrame.origin.x < popupMenuInsets.left {
                    popupMenuFrame.origin.x = popupMenuInsets.left
                }

                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
                arrowPoint = CGPoint(x: max(cornerRadius, min(popupMenuFrame.size.width - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: 0)

            case .left:
                popupMenuFrame = CGRect(x: targetRect.origin.x + targetRect.size.width + margin, y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)

                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - popupMenuInsets.bottom {
                    popupMenuFrame.origin.y = view.frame.size.height - popupMenuInsets.bottom - popupMenuFrame.size.height
                }
                if popupMenuFrame.origin.y < popupMenuInsets.top {
                    popupMenuFrame.origin.y = popupMenuInsets.top
                }

                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
                arrowPoint = CGPoint(x: 0, y: max(cornerRadius, min(popupMenuFrame.size.height - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))

            case .right:
                popupMenuFrame = CGRect(x: targetRect.origin.x - (width + margin), y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)

                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - popupMenuInsets.bottom {
                    popupMenuFrame.origin.y = view.frame.size.height - popupMenuInsets.bottom - popupMenuFrame.size.height
                }
                if popupMenuFrame.origin.y < popupMenuInsets.top {
                    popupMenuFrame.origin.y = popupMenuInsets.top
                }

                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
                arrowPoint = CGPoint(x: popupMenuFrame.size.width, y: max(cornerRadius, min(popupMenuFrame.size.height - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))
        }

        // Round coordinates
        popupMenuFrame = CGRect(x: round(popupMenuFrame.origin.x), y: round(popupMenuFrame.origin.y), width: round(popupMenuFrame.size.width), height: round(popupMenuFrame.size.height))
        arrowPoint =     CGPoint(x: round(arrowPoint.x), y: round(arrowPoint.y))

        self.frame = popupMenuFrame
    }
    
    private func updatePopupMenuImage() {
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
        let y = (arrowDirection == .up) ? arrowSize : 0

        for i in 0 ..< visibleItemViews.count {
            let itemView = visibleItemViews[i]
            let frame = itemView.frame

            if i == 0 {
                if visibleItemViews.count == 1 {
                    var headRect = CGRect.zero
                    var bodyRect = CGRect.zero
                    var tailRect = CGRect.zero

                    if arrowDirection == .left {
                        headRect = CGRect(x: arrowSize, y: y, width: cornerRadius, height: height)
                        bodyRect = CGRect(x: arrowSize + cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius * 2.0), height: height)
                        tailRect = CGRect(x: frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
                    } else if arrowDirection == .right {
                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius * 2.0), height: height)
                        tailRect = CGRect(x: frame.size.width - (arrowSize + cornerRadius), y: y, width: cornerRadius, height: height)
                    } else {
                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - cornerRadius * 2.0, height: height)
                        tailRect = CGRect(x: frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
                    }

                    drawHeadIn(rect: headRect, highlighted: highlighted)
                    drawBodyIn(rect: bodyRect, lastItem: true, highlighted: highlighted)
                    drawTailIn(rect: tailRect, highlighted: highlighted)
                } else {
                    var headRect = CGRect.zero
                    var bodyRect = CGRect.zero

                    if arrowDirection == .left {
                        headRect = CGRect(x: arrowSize, y: y, width: cornerRadius, height: height)
                        bodyRect = CGRect(x: arrowSize + cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius), height: height)
                    } else {
                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - cornerRadius, height: height)
                    }

                    drawHeadIn(rect: headRect, highlighted: highlighted)
                    drawBodyIn(rect: bodyRect, lastItem: false, highlighted: highlighted)
                }
            } else if i == visibleItemViews.count - 1 {
                var bodyRect = CGRect.zero
                var tailRect = CGRect.zero

                if arrowDirection == .right {
                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - (cornerRadius + arrowSize), height: height)
                    tailRect = CGRect(x: frame.origin.x + frame.size.width - (cornerRadius + arrowSize), y: y, width: cornerRadius, height: height)
                } else {
                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - cornerRadius, height: height)
                    tailRect = CGRect(x: frame.origin.x + frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
                }

                drawBodyIn(rect: bodyRect, lastItem: true, highlighted: highlighted)
                drawTailIn(rect: tailRect, highlighted: highlighted)
            } else {
                // Draw body
                let bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: height)
                drawBodyIn(rect: bodyRect, lastItem: false, highlighted: highlighted)
            }
        }

        // Draw arrow
        drawArrowAt(point: arrowPoint, highlighted: highlighted)

        // Create image from buffer
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    private func drawPath(path: CGPath, highlighted:Bool) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()
        context.addPath(path)
        context.setFillColor((highlighted ? highlightedColor : color).cgColor)
        context.fillPath()
        context.restoreGState()
    }
    
   private func drawArrowIn(rect: CGRect, highlighted:Bool)
    {
        drawPath(path: arrowPathIn(rect: rect), highlighted: highlighted)

        // Separator
        if arrowDirection == .down || arrowDirection == .up {
            for itemView in visibleItemViews {
                drawSeparatorIn(rect: CGRect(x: itemView.frame.origin.x + itemView.frame.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
            }
        }
    }
    
    private func drawHeadIn(rect: CGRect, highlighted:Bool) {
        drawPath(path: headPathIn(rect: rect), highlighted: highlighted)
    }
    
    private func drawTailIn(rect: CGRect, highlighted:Bool) {
        drawPath(path: tailPathIn(rect: rect), highlighted: highlighted)
    }

    private func drawBodyIn(rect: CGRect, lastItem: Bool, highlighted: Bool) {
        drawPath(path: bodyPathIn(rect: rect), highlighted: highlighted)

        // Separator
        if !lastItem {
            drawSeparatorIn(rect: CGRect(x: rect.origin.x + rect.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
        }
    }

    private func drawSeparatorIn(rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else {
                return
            }

            // Separator
            context.saveGState()
            context.clear(rect)
            context.restoreGState()
        }
    
    private func drawArrowAt(point: CGPoint, highlighted: Bool) {
        var arrowRect = CGRect.zero

        switch arrowDirection {
            case .down:
                arrowRect = CGRect(x: point.x - arrowSize + 1.0, y: point.y - arrowSize, width: arrowSize * 2.0 - 1.0, height: arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, cornerRadius), frame.size.width - cornerRadius - arrowRect.size.width)
            case .up:
                arrowRect = CGRect(x: point.x - arrowSize + 1.0, y: 0, width: arrowSize * 2.0 - 1.0, height: arrowSize)
                arrowRect.origin.x = min(max(arrowRect.origin.x, self.cornerRadius), self.frame.size.width - self.cornerRadius - arrowRect.size.width)
            case .left:
                arrowRect = CGRect(x: 0, y: point.y - arrowSize + 1.0, width: arrowSize, height: arrowSize * 2.0 - 1.0)
            case .right:
                arrowRect = CGRect(x: point.x - arrowSize, y: point.y - arrowSize + 1.0, width: arrowSize, height: arrowSize * 2.0 - 1.0)
        }

        drawArrowIn(rect: arrowRect, highlighted: highlighted)
    }
}

extension QBPopupMenu {

    private func arrowPathIn(rect: CGRect) -> CGPath {
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

    private func headPathIn(rect: CGRect) -> CGPath {
        return drawPath([
                .moveTo(rect.origin.x, rect.origin.y + cornerRadius),
                .arcTo (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
                .lineTo(rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
                .arcTo (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius),
         ])
     }
    
    private func tailPathIn(rect:CGRect) -> CGPath {
        return drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
            .arcTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
    }

    private func bodyPathIn(rect: CGRect) -> CGPath {
        return drawPath([
            .moveTo(rect.origin.x, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
        ])
     }
}
