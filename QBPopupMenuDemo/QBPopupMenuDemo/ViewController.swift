//  QBPopupMenuDemo rewritten into Swift
//  https://github.com/dsaiko/QBPopupMenu/

import Foundation
import UIKit

class ViewController: UIViewController {
    
    var popupMenu: QBPopupMenu!
    //@property (nonatomic, strong) QBPlasticPopupMenu *plasticPopupMenu;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let items = [
            QBPopupMenu.Item(title: "Hello", action:                                     { self.action() }),
            QBPopupMenu.Item(title: "Cut", action:                                       { self.action() }),
            QBPopupMenu.Item(title: "Copy", action:                                      { self.action() }),
            QBPopupMenu.Item(title: "Delete", action:                                    { self.action() }),
            QBPopupMenu.Item(image: UIImage(named: "clip"), action:                      { self.action() }),
            QBPopupMenu.Item(title: "Delete", image: UIImage(named: "trash"), action:    { self.action() })
        ]
        
        popupMenu = QBPopupMenu(items: items)
        
        //    QBPlasticPopupMenu *plasticPopupMenu = [[QBPlasticPopupMenu alloc] initWithItems:items];
        //    plasticPopupMenu.height = 40;
        //    self.plasticPopupMenu = plasticPopupMenu;
    }
    
    func action() {
        print("QBPopupMenuAction!")
    }
    
    @IBAction func showPopupMenu(_ sender: Any) {
        let button = sender as! UIButton
        popupMenu.showIn(view: self.view, targetRect: button.frame, animated: true)
    }
    
    @IBAction func showPlasticPopupMenu(_ sender: Any) {
        let button = sender as! UIButton
        //[self.plasticPopupMenu showInView:self.view targetRect:button.frame animated:YES];
    }
}

