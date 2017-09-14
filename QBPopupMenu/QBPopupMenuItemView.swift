//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

class QBPopupMenuItemView: UIView {

    weak var popupMenu: QBPopupMenu?
    let button: UIButton
    let item: QBPopupMenuItem?

    init(popupMenu: QBPopupMenu, item: QBPopupMenuItem? = nil) {

        self.popupMenu = popupMenu
        self.item = item
        self.button = UIButton(type: .custom)
        
        super.init(frame: .zero)

        isOpaque = false
        backgroundColor = UIColor.clear
        clipsToBounds = true

        button.addTarget(self, action: #selector(performAction), for: .touchUpInside)
        button.frame = self.bounds
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
        self.frame.size = sizeThatFits(.zero)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var buttonSize = button.sizeThatFits(.zero)
        buttonSize.width += 10 * 2

        return buttonSize
    }
}
