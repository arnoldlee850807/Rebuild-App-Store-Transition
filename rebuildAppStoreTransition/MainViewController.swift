//
//  MainViewController.swift
//  rebuildAppStoreTransition
//
//  Created by Arnold Lee on 4/16/18.
//  Copyright © 2018 Arnold Lee. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var frankCollectionView: UICollectionView!
    
    let transition = TransitionClone()
    
    let picture = [#imageLiteral(resourceName: "colored frankenstein "), #imageLiteral(resourceName: "colored zombie "), #imageLiteral(resourceName: "colored viking "), #imageLiteral(resourceName: "colored caveman "), #imageLiteral(resourceName: "colored wrestler ")]
    let label = ["frankenstein","zombie","viking","caveman","wrestler"]
    
    var collectionIndex: IndexPath?
    
    var imageFrame = CGRect.zero
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picture.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! frankCollectionViewCell
        cell.myImage.image = picture[indexPath.row]
        cell.myImage.layer.cornerRadius = 5
        cell.myLabel.text = "Hi, I'm \(label[indexPath.row])"
        cell.shadowView.layer.cornerRadius = 15
        cell.shadowView.layer.masksToBounds = false
        cell.shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cell.shadowView.layer.shadowOffset = CGSize(width: 15, height: 15)
        cell.shadowView.layer.shadowOpacity = 0.8
        
        ////
        transition.destinationFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: cell.myImage.frame.height * view.frame.width / cell.myImage.frame.width)
        ////
        
        imageFrame = cell.myImage.frame
        print("\(imageFrame)")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        
        print("didHighlight")
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.3) {
            cell?.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionIndex = indexPath
        print("didSelect")
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabHeight = tabFrame?.size.height
        tabFrame?.origin = CGPoint(x: 0, y: self.view.frame.size.height + tabHeight!)
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = tabFrame!
        })
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            let a = collectionView.convert(cell.frame, to: collectionView.superview)
            
            ////
            transition.startingFrame = CGRect(x: a.minX+14, y: a.minY+14, width: imageFrame.width, height: imageFrame.height)
            ////
            
            print("cell miny\(a.minY)")
            let sb = storyboard?.instantiateViewController(withIdentifier: "detail") as! DetailViewController
            sb.image = picture[indexPath.row]
            sb.transitioningDelegate = self
            sb.modalPresentationStyle = .custom

            self.present(sb, animated: true, completion: nil)
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarShow), name: NSNotification.Name(rawValue: "tabBarShow"), object: nil)
    }
    
    @objc func tabBarShow(){
        var tabFrame = self.tabBarController?.tabBar.frame
        let tabHeight = tabFrame?.size.height
        tabFrame?.origin.y = self.view.frame.size.height - tabHeight!
        UIView.animate(withDuration: 0.5, animations: {
            self.tabBarController?.tabBar.frame = tabFrame!
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
