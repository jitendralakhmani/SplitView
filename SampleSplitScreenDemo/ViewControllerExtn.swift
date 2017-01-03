import Foundation
import UIKit

enum Direction{ case Up
    case Down
    case None }

fileprivate var isExpanded: Bool = false
fileprivate var directn: Direction = .None
fileprivate var topImageView = UIImageView()
fileprivate var bottomImageView = UIImageView()
fileprivate var innerViewHeight: CGFloat = 0.0
fileprivate var innerViewWidth: CGFloat = 0.0
fileprivate var viewWidth: CGFloat = 0.0
fileprivate var viewHeight: CGFloat = 0.0
fileprivate var yPos: CFloat = 0.0
fileprivate var tapGestureInnerView: UITapGestureRecognizer!
fileprivate var tapGestureOuterView: UITapGestureRecognizer!
fileprivate var outerViewTapping : (()->())!
fileprivate var innerViewTapping : (()->())!
fileprivate var initialFrameOffsetTopView: CGFloat = 0.0
fileprivate var initialFrameOffsetBottomView: CGFloat = 0.0
fileprivate var finalFrameOffsetTopView: CGFloat = 0.0
fileprivate var finalFrameOffsetBottomView: CGFloat = 0.0
fileprivate var finalInnerViewWidth: CGFloat = 0.0
fileprivate var finalInnerViewHeigth: CGFloat = 0.0

extension UIViewController{
    
    func setUpAllViews(yPosition: CGFloat, innerView: UIView, mainView: UIView, viewController: UIViewController.Type){
        isExpanded = false
        innerViewHeight = innerView.frame.size.height
        innerViewWidth = innerView.frame.size.width
        viewWidth = self.view.frame.size.width
        viewHeight = self.view.frame.size.height
        finalInnerViewWidth = innerViewWidth
        finalInnerViewHeigth = innerViewHeight
        yPos = CFloat(yPosition)
        topImageView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: yPosition)
        bottomImageView.frame = CGRect(x: 0, y: yPosition, width: viewWidth, height: viewHeight - yPosition)
        topImageView.isHidden = true
        bottomImageView.isHidden = true
        self.view.addSubview(topImageView)
        self.view.addSubview(bottomImageView)
        self.setImagesOnViews(img: self.takeScreenShot(),yPosition: yPosition)
        innerView.frame = CGRect(x: (viewWidth)/2, y: (CGFloat(yPos)), width: 0, height: 0)
        self.intializeOuterTap(viewController: viewController.self) {
            mainView.isHidden = true
            self.expandView(innerView: innerView, completion: ({}))
        }
        self.intializeInnerTap(viewController: viewController.self) {
            self.collapseView(innerView: innerView, completion: {
                mainView.isHidden = false
            })
        }
    }
    
    fileprivate func setImagesOnViews(img: UIImage, yPosition: CGFloat){
        topImageView.image = img.crop(rect: CGRect(x: 0, y: 0, width: img.size.width, height: yPosition))
        bottomImageView.image = img.crop(rect: CGRect(x: 0, y: yPosition, width: img.size.width, height: img.size.height - yPosition))
    }
    
    fileprivate func intializeInnerTap(viewController: UIViewController.Type, todo: (()->())!){
        tapGestureInnerView = UITapGestureRecognizer(target: self, action: #selector(viewController.collapseViewOnTap(gesture:)))
        innerViewTapping = todo
    }
    
    fileprivate func intializeOuterTap(viewController: UIViewController.Type, todo: (()->())!){
        tapGestureOuterView = UITapGestureRecognizer(target: self, action: #selector(viewController.expandViewOnTap(gesture:)))
        outerViewTapping = todo
    }
    
    fileprivate func takeScreenShot()->UIImage{
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, self.view.isOpaque, UIScreen.main.scale)
        self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    fileprivate func toggleInnerView(innerView: UIView, completion: (()->())!){
        topImageView.isHidden = false
        bottomImageView.isHidden = false
        self.setFramesOffsetsForViews()
        if isExpanded{
            UIView.animate(withDuration: 0.8, animations: {
                topImageView.frame.origin.y = initialFrameOffsetTopView
                bottomImageView.frame.origin.y = initialFrameOffsetBottomView
                self.manageInnerViewFrames(topViewYFrame: topImageView.frame.origin.y, bottomViewYFrame: bottomImageView.frame.origin.y, finalInnerViewWidth: 0, innerView: innerView)
                isExpanded = false
                }, completion: { (bool) in
                    topImageView.isHidden = true
                    bottomImageView.isHidden = true
                    completion()
            })
        }else{
            UIView.animate(withDuration: 0.8, animations: {
                topImageView.frame.origin.y = finalFrameOffsetTopView
                bottomImageView.frame.origin.y = finalFrameOffsetBottomView
                self.manageInnerViewFrames(topViewYFrame: topImageView.frame.origin.y, bottomViewYFrame: bottomImageView.frame.origin.y, finalInnerViewWidth: finalInnerViewWidth, innerView: innerView)
                isExpanded = true
                }, completion: { (bool) in
                    completion()
            })
        }
    }
    
    fileprivate func setFramesOffsetsForViews(){
        switch directn {
        case .Up:
            initialFrameOffsetTopView = 0.0
            initialFrameOffsetBottomView = CGFloat(yPos)
            finalFrameOffsetTopView = -(innerViewHeight + 10)
            finalFrameOffsetBottomView = initialFrameOffsetBottomView
            break
        case .Down:
            initialFrameOffsetTopView = 0.0
            initialFrameOffsetBottomView = CGFloat(yPos)
            finalFrameOffsetTopView = initialFrameOffsetTopView
            finalFrameOffsetBottomView = initialFrameOffsetBottomView + CGFloat(innerViewHeight) + 10
            break
        case .None:
            initialFrameOffsetTopView = 0.0
            initialFrameOffsetBottomView = CGFloat(yPos)
            finalFrameOffsetTopView = initialFrameOffsetTopView - (innerViewHeight/2 + 10)
            finalFrameOffsetBottomView = initialFrameOffsetBottomView + (innerViewHeight/2 + 10)
            break
        }
    }

    fileprivate func manageInnerViewFrames(topViewYFrame: CGFloat, bottomViewYFrame: CGFloat, finalInnerViewWidth: CGFloat, innerView: UIView){
        
            switch directn {
            case .Up:
                let height = (-topViewYFrame) - 10
                innerView.frame = CGRect(x: (viewWidth - finalInnerViewWidth)/2, y: (CGFloat(yPos) - CGFloat(height) - 5), width: finalInnerViewWidth, height: height)
                print(innerView.frame.origin.x)
                break
            case .Down:
                let height = (bottomViewYFrame - initialFrameOffsetBottomView) - 10
                innerView.frame = CGRect(x: (viewWidth - finalInnerViewWidth)/2, y: CGFloat(yPos) + 5, width: finalInnerViewWidth, height: height)
                break
            case .None:
                let height = ((-(topViewYFrame))*2) - 10
                innerView.frame = CGRect(x: (viewWidth - finalInnerViewWidth)/2, y: (CGFloat(yPos) - CGFloat(height/2)), width: finalInnerViewWidth, height: height)
                break
            }
    }
    
    func setDirection(direction: Direction){
        directn = direction
    }
    
    func collapseView(innerView: UIView, completion: (()->())!){
        isExpanded = true
        toggleInnerView(innerView: innerView) { 
            completion()
        }
    }
    
    func expandView(innerView: UIView, completion: (()->())!){
        isExpanded = false
        toggleInnerView(innerView: innerView) { 
            completion()
        }
    }
    
    func enableTapGestureOnViews(innerView: UIView, mainView: UIView){
        innerView.addGestureRecognizer(tapGestureInnerView)
        mainView.addGestureRecognizer(tapGestureOuterView)
    }
    
    func disableTapGestureOnViews(innerView: UIView, mainView: UIView){
        innerView.removeGestureRecognizer(tapGestureInnerView)
        mainView.removeGestureRecognizer(tapGestureOuterView)
    }
    
    @objc fileprivate func collapseViewOnTap(gesture: UITapGestureRecognizer){
        innerViewTapping()
    }
    
    @objc fileprivate func expandViewOnTap(gesture: UITapGestureRecognizer){
        outerViewTapping()
    }
    
    fileprivate func removeStatusBarImage(img: UIImage)-> UIImage{
        let rect = CGRect(x: 0, y: 20, width: img.size.width, height: img.size.height - 20)
        let imageRef: CGImage = img.cgImage!.cropping(to: rect)!
        let croppedImg: UIImage = UIImage(cgImage: imageRef)
        return croppedImg
    }
}
