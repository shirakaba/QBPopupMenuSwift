//
//  QBPopupMenuOverlayView.swift
//  QBPopupMenuDemo
//
//  Created by Dusan Saiko on 06/09/2017.
//

import Foundation

class QBPopupMenuOverlayView : UIView
{

    private(set) weak var popupMenu: QBPopupMenu?
    
    init(frame: CGRect, popupMenu: QBPopupMenu) {
        self.popupMenu = popupMenu
        super.init(frame: frame)
        setBackround()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) can not be used.")
    }
    
    func setBackround() {
        backgroundColor = UIColor.clear
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)

        if view === self {
            self.popupMenu?.dismiss(animated: true)
            return nil
        }
        
        return view
    }
}
