////  QBPopupMenuDemo rewritten into Swift
////  https://github.com/dsaiko/QBPopupMenu/
//
//import Foundation
//
//protocol QBPopupMenuDelegate: class {
//    func popupMenuWillAppear    (menu: QBPopupMenu)
//    func popupMenuDidAppear     (menu: QBPopupMenu)
//    func popupMenuWillDisappear (menu: QBPopupMenu)
//    func popupMenuDidDisappear  (menu: QBPopupMenu)
//}
//
//class QBPopupMenu: UIView {
//
//    private(set) var itemViews: [QBPopupMenuItemView]!
//    var groupedItemViews: [[QBPopupMenuItemView]]?
//    var visibleItemViews: [QBPopupMenuItemView]?
//    
//    let popupMenuInsets: UIEdgeInsets
//    let margin: CGFloat
//    let cornerRadius: CGFloat
//    let color: UIColor
//    let highlightedColor: UIColor
//    let arrowSize: CGFloat
//    
//    var targetRect: CGRect?
//    weak var view: UIView?
//    var arrowDirection: QBPopupMenuArrowDirection
//    var page: Int
//    var arrowPoint: CGPoint?
//
//
//    weak var  delegate: QBPopupMenuDelegate?
//
//    init(items: [QBPopupMenuItem]) {
//
//        self.popupMenuInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        self.margin = 2
//        self.cornerRadius = 8
//        self.arrowSize = 9
//        self.page = 0
//
//        self.color = UIColor.black.withAlphaComponent(0.8)
//        self.highlightedColor = UIColor.darkGray.withAlphaComponent(0.8)
//        self.arrowDirection = .auto
//
//        super.init(frame: .zero)
//
//        self.itemViews = [QBPopupMenuItemView]()
//
//        for item in items {
//            itemViews.append(QBPopupMenuItemView(item: item, popupMenu: self))
//        }
//
//        isOpaque = false
//        backgroundColor = UIColor.clear
//        clipsToBounds = true
//
//        height = 36
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) can not be used.")
//    }
//
//    var height: CGFloat {
//        get {
//            return self.frame.height
//        }
//        set(newValue) {
//            self.frame.size.height = newValue
//        }
//    }
//
//
//    func showInView(view: UIView, targetRect: CGRect, animated: Bool) {
//        
//        var topMenuInset = self.popupMenuInsets.top
//        
//        //If iPhone in landscape mode ONLY then menu shoudn't be shown over navigation bar
//        if !(UI_USER_INTERFACE_IDIOM() == .pad) && !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
//            topMenuInset = 2*self.popupMenuInsets.top
//        }
//            
//        self.view = view
//        self.targetRect = targetRect
//            
//        //fix bug #6172; Its need not for only default direction
//        if (targetRect.origin.y - (self.height + self.arrowSize)) >= topMenuInset {
//            arrowDirection = .down
//        } else if (targetRect.origin.y + targetRect.size.height + (self.height + self.arrowSize)) < (view.bounds.size.height - self.popupMenuInsets.bottom) {
//            arrowDirection = .up
//        } else {
//            let left = targetRect.origin.x - self.popupMenuInsets.left
//            let right = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + self.popupMenuInsets.right)
//            
//            arrowDirection = (left > right) ? .left : .right
//        }
//
//        var maximumWidth: CGFloat = 0
//        var minimumWidth: CGFloat = 40
//            
//        switch (arrowDirection) {
//            case .down, .up:
//                maximumWidth = view.bounds.size.width - (self.popupMenuInsets.left + self.popupMenuInsets.right)
//                if maximumWidth < minimumWidth {
//                    maximumWidth = minimumWidth
//                }
//            
//            case .left:
//                maximumWidth = targetRect.origin.x - self.popupMenuInsets.left
//            
//            case .right:
//                maximumWidth = view.bounds.size.width - (targetRect.origin.x + targetRect.size.width + self.popupMenuInsets.right)
//            default:
//                break
//        }
//        
//        groupItemViewsWithMaximumWidth(maximumWidth)
//        
//        showPage(0)
//        
////            // fix fast show/hide popupMenu and show 1+ overlayViews
////            [self.overlayView removeFromSuperview]
////
////            // Create overlay view
////            self.overlayView = [[QBPopupMenuOverlayView alloc] initWithFrame:view.bounds popupMenu:self]
////
////            // Delegate
////            if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuWillAppear:)]) {
////                [self.delegate popupMenuWillAppear:self]
////            }
////
////            // Show
////            [view addSubview:self.overlayView]
////
////            //Must set this immediately. otherwise, a client can call dismiss while this is animating in
////            //and it will be a no-op and the popup will still be visible
////            self.visible = YES
////
////            if (animated) {
////                self.alpha = 0
////                [self.overlayView addSubview:self]
////
////                [UIView animateWithDuration:kQBPopupMenuAnimationDuration animations:^(void) {
////                    self.alpha = 1.0
////                    } completion:^(BOOL finished) {
////
////
////                    // Delegate
////                    if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
////                    [self.delegate popupMenuDidAppear:self]
////                    }
////                    }]
////            } else {
////                [self.overlayView addSubview:self]
////
////                // Delegate
////                if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
////                    [self.delegate popupMenuDidAppear:self]
////                }
////            }
//    }
//    
//    
//    func groupItemViewsWithMaximumWidth(_ maximumWidth: CGFloat) {
//        var groupedItemViews = [[QBPopupMenuItemView]]()
//
//        let pagenatorWidth = QBPopupMenuPagenatorView.pagenatorWidth
//        
//        // Create new array
//        var itemViews = [QBPopupMenuItemView]()
//        var width: CGFloat = 0
//        
//        
//        if self.arrowDirection == .left || self.arrowDirection == .right {
//            width += self.arrowSize
//        }
//        
//        for itemView in self.itemViews {
//            // Clear state
//            resetItemViewState(itemView)
//            
//            let itemViewSize = itemView.sizeThatFits(.zero)
//            let isLastItem = (itemView === self.itemViews.last)
//            
//            let sizeToAdd = isLastItem ? itemViewSize.width : (itemViewSize.width + pagenatorWidth)
//            
//            if itemViews.count > 0 && width + sizeToAdd > maximumWidth {
//                groupedItemViews.append(itemViews)
//                
//                // Create new array
//                itemViews = [QBPopupMenuItemView]()
//                width = pagenatorWidth
//                if self.arrowDirection == .left || self.arrowDirection == .right {
//                    width += self.arrowSize
//                }
//            }
//            
//            itemViews.append(itemView)
//            width += itemViewSize.width
//        }
//        
//        if (itemViews.count > 0) {
//            groupedItemViews.append(itemViews)
//        }
//        
//        self.groupedItemViews = groupedItemViews
//    }
//    
//    func resetItemViewState(_ itemView: QBPopupMenuItemView)
//    {
//        // NOTE: Reset properties related to the size of the button before colling sizeThatFits: of item view,
//        //       or the size of the view will change from the second time.
//        itemView.button.contentEdgeInsets = .zero
//        itemView.image = nil
//        itemView.highlightedImage = nil
//    }
//    
//    func showPage(_ page: Int) {
//        self.page = page
//        
//        updateVisibleItemViews()
//        layoutVisibleItemViews()
//        updatePopupMenuFrameAndArrowPosition()
//        updatePopupMenuImage()
//    }
//    
//    func showPreviousPage() {
//        showPage(self.page - 1)
//    }
//    
//    func showNextPage() {
//        showPage(self.page + 1)
//    }
//    
//    private func updateVisibleItemViews() {
//        // Remove all visible item views
//        for view in self.visibleItemViews ?? [] {
//            view.removeFromSuperview()
//        }
//        
//        // Add item views
//        var visibleItemViews = [QBPopupMenuItemView]()
//        let numberOfPages = self.groupedItemViews?.count ?? 0
//        
//        assert(numberOfPages >= page)
//        
//        if numberOfPages > 1 && page != 0 {
//            let leftPagenatorView = QBPopupMenuPagenatorView(direction: .left) {
//                self.showPreviousPage()
//            }
//
//            addSubview(leftPagenatorView)
//            visibleItemViews.append(leftPagenatorView)
//        }
//        
//        for itemView in groupedItemViews?[page] ?? [] {
//            addSubview(itemView)
//            visibleItemViews.append(itemView)
//        }
//        
//        
//        if numberOfPages > 1 && page != numberOfPages - 1 {
//            let rightPagenatorView = QBPopupMenuPagenatorView(direction: .right) {
//                self.showNextPage()
//            }
//            
//            addSubview(rightPagenatorView)
//            visibleItemViews.append(rightPagenatorView)
//        }
//        
//        self.visibleItemViews = visibleItemViews
//    }
//    
//    private func layoutVisibleItemViews() {
//        guard  let visibleItemViews = self.visibleItemViews else {
//            return
//        }
//        
//        var height = self.height
//        
//        if self.arrowDirection == .down || self.arrowDirection == .up {
//            height += self.arrowSize
//        }
//        
//        var offset: CGFloat = 0
//        
//        for i in 0 ..< visibleItemViews.count {
//            let itemView = visibleItemViews[i]
//            
//            // Clear state
//            resetItemViewState(itemView)
//            
//            // Set item view insets
//            if i == 0 && arrowDirection == .left {
//                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, arrowSize, 0, 0)
//            } else if i == visibleItemViews.count - 1 && arrowDirection == .right {
//                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, arrowSize)
//            } else if arrowDirection == .down {
//                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, arrowSize, 0)
//            } else if arrowDirection == .up {
//                itemView.button.contentEdgeInsets = UIEdgeInsetsMake(arrowSize, 0, 0, 0)
//            }
//            
//            // Set item view frame
//            let size = itemView.sizeThatFits(.zero)
//            var width = size.width
//            
//            if (i == 0 && arrowDirection == .left) || (i == visibleItemViews.count - 1 && arrowDirection == .right) {
//                width += arrowSize
//            }
//            
//            itemView.frame = CGRect(x: offset, y: 0, width: width, height: height)
//            
//            offset += width
//        }
//    }
//    
//    private func updatePopupMenuFrameAndArrowPosition() {
//        guard
//            let visibleItemViews = self.visibleItemViews,
//            let itemView = visibleItemViews.last,
//            let targetRect = targetRect,
//            let view = view
//        else {
//            return
//        }
//        
//        // Calculate popup frame
//        var popupMenuFrame = CGRect.zero
//        var arrowPoint = CGPoint.zero
//        
//        let width = itemView.frame.origin.x + itemView.frame.size.width
//        let height = itemView.frame.origin.y + itemView.frame.size.height
//        
//        switch arrowDirection {
//            case .down:
//                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y - (height + margin), width: width, height: height)
//                
//                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - popupMenuInsets.right {
//                    popupMenuFrame.origin.x = view.frame.size.width - popupMenuInsets.right - popupMenuFrame.size.width
//                }
//                if popupMenuFrame.origin.x < popupMenuInsets.left {
//                    popupMenuFrame.origin.x = popupMenuInsets.left
//                }
//                
//                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
//                arrowPoint = CGPoint(x: max(cornerRadius, min(popupMenuFrame.size.width - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: popupMenuFrame.size.height)
//                    
//            case .up:
//                popupMenuFrame = CGRect(x: targetRect.origin.x + (targetRect.size.width - width) / 2.0, y: targetRect.origin.y + targetRect.size.height + margin, width: width, height: height)
//                
//                if popupMenuFrame.origin.x + popupMenuFrame.size.width > view.frame.size.width - popupMenuInsets.right {
//                    popupMenuFrame.origin.x = view.frame.size.width - popupMenuInsets.right - popupMenuFrame.size.width
//                }
//                if popupMenuFrame.origin.x < popupMenuInsets.left {
//                    popupMenuFrame.origin.x = popupMenuInsets.left
//                }
//                
//                let centerOfTargetRect = targetRect.origin.x + targetRect.size.width / 2.0
//                arrowPoint = CGPoint(x: max(cornerRadius, min(popupMenuFrame.size.width - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.x)), y: 0)
//
//            case .left:
//                popupMenuFrame = CGRect(x: targetRect.origin.x + targetRect.size.width + margin, y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)
//                
//                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - popupMenuInsets.bottom {
//                    popupMenuFrame.origin.y = view.frame.size.height - popupMenuInsets.bottom - popupMenuFrame.size.height
//                }
//                if popupMenuFrame.origin.y < popupMenuInsets.top {
//                    popupMenuFrame.origin.y = popupMenuInsets.top
//                }
//                
//                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
//                arrowPoint = CGPoint(x: 0, y: max(cornerRadius, min(popupMenuFrame.size.height - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))
//
//            case .right:
//                popupMenuFrame = CGRect(x: targetRect.origin.x - (width + margin), y: targetRect.origin.y + (targetRect.size.height - height) / 2.0, width: width, height: height)
//
//                if popupMenuFrame.origin.y + popupMenuFrame.size.height > view.frame.size.height - popupMenuInsets.bottom {
//                    popupMenuFrame.origin.y = view.frame.size.height - popupMenuInsets.bottom - popupMenuFrame.size.height
//                }
//                if popupMenuFrame.origin.y < popupMenuInsets.top {
//                    popupMenuFrame.origin.y = popupMenuInsets.top
//                }
//                
//                let centerOfTargetRect = targetRect.origin.y + targetRect.size.height / 2.0
//                arrowPoint = CGPoint(x: popupMenuFrame.size.width, y: max(cornerRadius, min(popupMenuFrame.size.height - cornerRadius, centerOfTargetRect - popupMenuFrame.origin.y)))
//
//            default:
//                assertionFailure()
//        }
//        
//        // Round coordinates
//        popupMenuFrame = CGRect(x: round(popupMenuFrame.origin.x), y: round(popupMenuFrame.origin.y), width: round(popupMenuFrame.size.width), height: round(popupMenuFrame.size.height))
//        arrowPoint =     CGPoint(x: round(arrowPoint.x), y: round(arrowPoint.y))
//        
//        self.frame = popupMenuFrame
//        self.arrowPoint = arrowPoint
//    }
//    
//    private func updatePopupMenuImage() {
////        UIImage *popupMenuImage = [self popupMenuImageWithHighlighted:NO]
////        UIImage *popupMenuHighlightedImage = [self popupMenuImageWithHighlighted:YES]
////
////        for (NSInteger i = 0; i < self.visibleItemViews.count; i++) {
////            QBPopupMenuItemView *itemView = [self.visibleItemViews objectAtIndex:i]
////
////            UIImage *image = [self cropImageFromImage:popupMenuImage inRect:itemView.frame]
////            UIImage *highlightedImage = [self cropImageFromImage:popupMenuHighlightedImage inRect:itemView.frame]
////
////            itemView.image = image
////            itemView.highlightedImage = highlightedImage
////        }
//    }
//    
//    func popupMenuImage(highlighted: Bool) -> UIImage? {
//        guard
//            let visibleItemViews = self.visibleItemViews
//        else {
//                return nil
//        }
//        
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
//        
//        // Draw body
//        let y = (arrowDirection == .up) ? arrowSize : 0
//        let height = self.height
//        
////        for i in 0 ..< visibleItemViews.count {
////            let itemView = visibleItemViews[i]
////            let frame = itemView.frame
//        
////            if i == 0 {
////                if visibleItemViews.count == 1 {
////                    var headRect = CGRect.zero
////                    var bodyRect = CGRect.zero
////                    var tailRect = CGRect.zero
////
////                    if arrowDirection == .left {
////                        headRect = CGRect(x: arrowSize, y: y, width: cornerRadius, height: height)
////                        bodyRect = CGRect(x: arrowSize + cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius * 2.0), height: height)
////                        tailRect = CGRect(x: frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
////                    } else if arrowDirection == .right {
////                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
////                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius * 2.0), height: height)
////                        tailRect = CGRect(x: frame.size.width - (arrowSize + cornerRadius), y: y, width: cornerRadius, height: height)
////                    } else {
////                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
////                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - cornerRadius * 2.0, height: height)
////                        tailRect = CGRect(x: frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
////                    }
////
////                    // Draw head
////                    [self drawHeadInRect:headRect cornerRadius:cornerRadius highlighted:highlighted]
////
////                    // Draw body
////                    [self drawBodyInRect:bodyRect firstItem:YES lastItem:YES highlighted:highlighted]
////
////                    // Draw tail
////                    [self drawTailInRect:tailRect cornerRadius:cornerRadius highlighted:highlighted]
////                } else {
////                    var headRect = CGRect.zero
////                    var bodyRect = CGRect.zero
////
////                    if arrowDirection == .left {
////                        headRect = CGRect(x: arrowSize, y: y, width: cornerRadius, height: height)
////                        bodyRect = CGRect(x: arrowSize + cornerRadius, y: y, width: frame.size.width - (arrowSize + cornerRadius), height: height)
////                    } else {
////                        headRect = CGRect(x: 0, y: y, width: cornerRadius, height: height)
////                        bodyRect = CGRect(x: cornerRadius, y: y, width: frame.size.width - cornerRadius, height: height)
////                    }
////
////                    // Draw head
////                    [self drawHeadInRect:headRect cornerRadius:cornerRadius highlighted:highlighted]
////
////                    // Draw body
////                    [self drawBodyInRect:bodyRect firstItem:YES lastItem:NO highlighted:highlighted]
////                }
////            } else if i == visibleItemViews.count - 1 {
////                var bodyRect = CGRect.zero
////                var tailRect = CGRect.zero
////
////                if arrowDirection == .right {
////                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - (cornerRadius + arrowSize), height: height)
////                    tailRect = CGRect(x: frame.origin.x + frame.size.width - (cornerRadius + arrowSize), y: y, width: cornerRadius, height: height)
////                } else {
////                    bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width - cornerRadius, height: height)
////                    tailRect = CGRect(x: frame.origin.x + frame.size.width - cornerRadius, y: y, width: cornerRadius, height: height)
////                }
////
////                // Draw body
////                [self drawBodyInRect:bodyRect firstItem:NO lastItem:YES highlighted:highlighted]
////
////                // Draw tail
////                [self drawTailInRect:tailRect cornerRadius: cornerRadius highlighted:highlighted]
////            } else {
////                // Draw body
////                CGRect bodyRect = CGRect(x: frame.origin.x, y: y, width: frame.size.width, height: height)
////                [self drawBodyInRect:bodyRect firstItem:NO lastItem:NO highlighted:highlighted]
////            }
////        }
//        
//        // Draw arrow
////        [self drawArrowAtPoint:arrowPoint arrowSize:arrowSize arrowDirection:arrowDirection highlighted:highlighted]
////
////        // Create image from buffer
////        UIImage *image = UIGraphicsGetImageFromCurrentImageContext()
////
////        UIGraphicsEndImageContext()
////
////        return image
//            
//            return nil
//    }
//        
//        
//        private func drawArrowIn(rect: CGRect, direction:QBPopupMenuArrowDirection, highlighted:Bool)
//        {
//            guard let context = UIGraphicsGetCurrentContext(),
//                  let visibleItemViews = self.visibleItemViews
//            else {
//                    return
//            }
//            
//            // Arrow
//            context.saveGState()
//            context.addPath(arrowPathIn(rect: rect, direction: direction))
//            let color = highlighted ? highlightedColor : self.color
//            context.setFillColor(color.cgColor)
//            context.fillPath()
//            context.restoreGState()
//
//            // Separator
//            if direction == .down || direction == .up {
//                for itemView in visibleItemViews {
//                    drawSeparatorIn(rect: CGRect(x: itemView.frame.origin.x + itemView.frame.size.width - 1, y: rect.origin.y, width: 1, height: rect.size.height))
//                }
//            }
//        }
//
////            - (void)drawHeadInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted
////        {
////            CGContextRef context = UIGraphicsGetCurrentContext()
////
////            // Head
////            CGContextSaveGState(context) {
////                CGMutablePathRef path = [self headPathInRect:rect cornerRadius:cornerRadius]
////                CGContextAddPath(context, path)
////
////                UIColor *color = highlighted ? self.highlightedColor : self.color
////                CGContextSetFillColorWithColor(context, [color CGColor])
////                CGContextFillPath(context)
////
////                CGPathRelease(path)
////            } CGContextRestoreGState(context)
////            }
////
////            - (void)drawTailInRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius highlighted:(BOOL)highlighted
////        {
////            CGContextRef context = UIGraphicsGetCurrentContext()
////
////            // Tail
////            CGContextSaveGState(context) {
////                CGMutablePathRef path = [self tailPathInRect:rect cornerRadius:cornerRadius]
////                CGContextAddPath(context, path)
////
////                UIColor *color = highlighted ? self.highlightedColor : self.color
////                CGContextSetFillColorWithColor(context, [color CGColor])
////                CGContextFillPath(context)
////
////                CGPathRelease(path)
////            } CGContextRestoreGState(context)
////            }
////
////            - (void)drawBodyInRect:(CGRect)rect firstItem:(BOOL)firstItem lastItem:(BOOL)lastItem highlighted:(BOOL)highlighted
////        {
////            CGContextRef context = UIGraphicsGetCurrentContext()
////
////            // Body
////            CGContextSaveGState(context) {
////                CGMutablePathRef path = [self bodyPathInRect:rect]
////                CGContextAddPath(context, path)
////
////                UIColor *color = highlighted ? self.highlightedColor : self.color
////                CGContextSetFillColorWithColor(context, [color CGColor])
////                CGContextFillPath(context)
////
////                CGPathRelease(path)
////            } CGContextRestoreGState(context)
////
////            // Separator
////            if (!lastItem) {
////                [self drawSeparatorInRect:CGRectMake(rect.origin.x + rect.size.width - 1, rect.origin.y, 1, rect.size.height)]
////            }
////            }
////
//        func drawSeparatorIn(rect: CGRect) {
//            guard let context = UIGraphicsGetCurrentContext() else {
//                return
//            }
//
//            // Separator
//            context.saveGState()
//            context.clear(rect)
//            context.restoreGState()
//        }
//    
//    func xxx() {
////        - (void)drawArrowAtPoint:(CGPoint)point arrowSize:(CGFloat)arrowSize arrowDirection:(QBPopupMenuArrowDirection)arrowDirection highlighted:(BOOL)highlighted
////        {
////            CGRect arrowRect = CGRectZero;
////
////            switch (arrowDirection) {
////            case QBPopupMenuArrowDirectionDown:
////            {
////                arrowRect = CGRectMake(point.x - arrowSize + 1.0,
////                                       point.y - arrowSize,
////                                       arrowSize * 2.0 - 1.0,
////                                       arrowSize);
////
////                arrowRect.origin.x = MIN(MAX(arrowRect.origin.x, self.cornerRadius),
////                                         self.frame.size.width - self.cornerRadius - arrowRect.size.width);
////            }
////            break;
////
////            case QBPopupMenuArrowDirectionUp:
////            {
////                arrowRect = CGRectMake(point.x - arrowSize + 1.0,
////                                       0,
////                                       arrowSize * 2.0 - 1.0,
////                                       arrowSize);
////
////                arrowRect.origin.x = MIN(MAX(arrowRect.origin.x, self.cornerRadius),
////                                         self.frame.size.width - self.cornerRadius - arrowRect.size.width);
////            }
////            break;
////
////            case QBPopupMenuArrowDirectionLeft:
////            {
////                arrowRect = CGRectMake(0,
////                                       point.y - arrowSize + 1.0,
////                                       arrowSize,
////                                       arrowSize * 2.0 - 1.0);
////            }
////            break;
////
////            case QBPopupMenuArrowDirectionRight:
////            {
////                arrowRect = CGRectMake(point.x - arrowSize,
////                                       point.y - arrowSize + 1.0,
////                                       arrowSize,
////                                       arrowSize * 2.0 - 1.0);
////            }
////            break;
////
////            default:
////                break;
////            }
////
////            [self drawArrowInRect:arrowRect direction:arrowDirection highlighted:highlighted];
////        }
//    }
//}
//
//extension QBPopupMenu: QBPopupMenuDrawing {
//
//    private func arrowPathIn(rect: CGRect, direction:QBPopupMenuArrowDirection) -> CGPath {
//        switch direction {
//            case .down:
//                return drawPath([
//                    .moveTo(rect.origin.x, rect.origin.y),
//                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
//                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height)
//                 ])
//            case .up:
//                return drawPath([
//                    .moveTo(rect.origin.x, rect.origin.y + rect.size.height),
//                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
//                    .lineTo(rect.origin.x + rect.size.width / 2.0, rect.origin.y)
//                ])
//            case .left:
//                return drawPath([
//                    .moveTo(rect.origin.x + rect.size.width, rect.origin.y),
//                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
//                    .lineTo(rect.origin.x, rect.origin.y + rect.size.height / 2.0)
//                    ])
//            case .right:
//                return drawPath([
//                    .moveTo(rect.origin.x, rect.origin.y),
//                    .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
//                    .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2.0)
//                    ])
//            default:
//                assertionFailure()
//                return CGMutablePath()
//        }
//    }
//
//    private func headPathIn(rect: CGRect, cornerRadius: CGFloat) -> CGPath {
//        return drawPath([
//                .moveTo(rect.origin.x, rect.origin.y + cornerRadius),
//                .arcTo (rect.origin.x, rect.origin.y, rect.origin.x + cornerRadius, rect.origin.y, cornerRadius),
//                .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
//                .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
//                .lineTo(rect.origin.x + cornerRadius, rect.origin.y + rect.size.height),
//                .arcTo (rect.origin.x, rect.origin.y + rect.size.height, rect.origin.x, rect.origin.y + rect.size.height - cornerRadius, cornerRadius),
//         ])
//     }
//    
//    private func tailPathIn(rect:CGRect, cornerRadius:CGFloat) -> CGPath {
//        return drawPath([
//            .moveTo(rect.origin.x, rect.origin.y),
//            .lineTo(rect.origin.x + rect.size.width - cornerRadius, rect.origin.y),
//            .arcTo (rect.origin.x + rect.size.width, rect.origin.y, rect.origin.x + rect.size.width, rect.origin.y + cornerRadius, cornerRadius),
//            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius),
//            .arcTo (rect.origin.x + rect.size.width, rect.origin.y + rect.size.height, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height, cornerRadius),
//            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
//        ])
//    }
//
//    private func bodyPathIn(rect: CGRect) -> CGPath {
//        return drawPath([
//            .moveTo(rect.origin.x, rect.origin.y),
//            .lineTo(rect.origin.x + rect.size.width, rect.origin.y),
//            .lineTo(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height),
//            .lineTo(rect.origin.x, rect.origin.y + rect.size.height),
//        ])
//     }
//}
//
///**
//
// 
// static const NSTimeInterval kQBPopupMenuAnimationDuration = 0.2
//
// @property (nonatomic, strong) QBPopupMenuOverlayView *overlayView
//
//
//
// **/
//
//
//
