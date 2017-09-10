//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation

protocol QBPopupMenuDelegate: class {
    func popupMenuWillAppear    (menu: QBPopupMenu)
    func popupMenuDidAppear     (menu: QBPopupMenu)
    func popupMenuWillDisappear (menu: QBPopupMenu)
    func popupMenuDidDisappear  (menu: QBPopupMenu)
}

class QBPopupMenu: UIView {

    private(set) var itemViews: [QBPopupMenuItemView]!
    let popupMenuInsets: UIEdgeInsets
    let margin: CGFloat
    let cornerRadius: CGFloat
    let color: UIColor
    let highlightedColor: UIColor
    let arrowSize: CGFloat
    
    var targetRect: CGRect?
    weak var view: UIView?
    var arrowDirection: QBPopupMenuArrowDirection
    var groupedItemViews: [[QBPopupMenuItemView]]?


    weak var  delegate: QBPopupMenuDelegate?

    init(items: [QBPopupMenuItem]) {

        self.popupMenuInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.margin = 2
        self.cornerRadius = 8
        self.arrowSize = 9

        self.color = UIColor.black.withAlphaComponent(0.8)
        self.highlightedColor = UIColor.darkGray.withAlphaComponent(0.8)
        self.arrowDirection = .auto

        super.init(frame: .zero)

        self.itemViews = [QBPopupMenuItemView]()

        for item in items {
            itemViews.append(QBPopupMenuItemView(item: item, popupMenu: self))
        }

        isOpaque = false
        backgroundColor = UIColor.clear
        clipsToBounds = true

        height = 36
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }

    var height: CGFloat {
        get {
            return self.frame.height
        }
        set(newValue) {
            self.frame.size.height = newValue
        }
    }


    func showInView(view: UIView, targetRect: CGRect, animated: Bool) {
        
        var topMenuInset = self.popupMenuInsets.top
        
        //If iPhone in landscape mode ONLY then menu shoudn't be shown over navigation bar
        if !(UI_USER_INTERFACE_IDIOM() == .pad) && !UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            topMenuInset = 2*self.popupMenuInsets.top
        }
            
        self.view = view
        self.targetRect = targetRect
            
        //fix bug #6172; Its need not for only default direction
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
        var minimumWidth: CGFloat = 40
            
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
            default:
                break
        }
        
//            // Layout item views
//            [self groupItemViewsWithMaximumWidth:maximumWidth];
//
//            // Show page
//            [self showPage:0];
//
//            // fix fast show/hide popupMenu and show 1+ overlayViews
//            [self.overlayView removeFromSuperview];
//
//            // Create overlay view
//            self.overlayView = [[QBPopupMenuOverlayView alloc] initWithFrame:view.bounds popupMenu:self];
//
//            // Delegate
//            if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuWillAppear:)]) {
//                [self.delegate popupMenuWillAppear:self];
//            }
//
//            // Show
//            [view addSubview:self.overlayView];
//
//            //Must set this immediately. otherwise, a client can call dismiss while this is animating in
//            //and it will be a no-op and the popup will still be visible
//            self.visible = YES;
//
//            if (animated) {
//                self.alpha = 0;
//                [self.overlayView addSubview:self];
//
//                [UIView animateWithDuration:kQBPopupMenuAnimationDuration animations:^(void) {
//                    self.alpha = 1.0;
//                    } completion:^(BOOL finished) {
//
//
//                    // Delegate
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
//                    [self.delegate popupMenuDidAppear:self];
//                    }
//                    }];
//            } else {
//                [self.overlayView addSubview:self];
//
//                // Delegate
//                if (self.delegate && [self.delegate respondsToSelector:@selector(popupMenuDidAppear:)]) {
//                    [self.delegate popupMenuDidAppear:self];
//                }
//            }
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
}

/**

 @property (nonatomic, assign, getter = isVisible, readonly) BOOL visible;

 @property (nonatomic, assign) QBPopupMenuArrowDirection arrowDirection;

 @property (nonatomic, strong) UIColor *color;
 @property (nonatomic, strong) UIColor *highlightedColor;

 static const NSTimeInterval kQBPopupMenuAnimationDuration = 0.2;

 @interface QBPopupMenu ()

 @property (nonatomic, assign, getter = isVisible, readwrite) BOOL visible;
 @property (nonatomic, strong) QBPopupMenuOverlayView *overlayView;


 @property (nonatomic, assign) NSUInteger page;
 @property (nonatomic, assign) QBPopupMenuArrowDirection actualArrorDirection;
 @property (nonatomic, assign) CGPoint arrowPoint;

 @property (nonatomic, strong) NSMutableArray *visibleItemViews;

 @end

 @end
 **/



