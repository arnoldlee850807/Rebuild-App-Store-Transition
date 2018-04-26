# Rebuilding AppStore Card Like Transition

## Introduction

Recreate the card like transition Apple made for the App Store "Today" category. By using collection view + pan gesture recognizer. 
This project is based on Swift 4.

Here's what it'll look like

![Example](https://github.com/arnoldlee850807/rebuildAppStoreTransition/blob/master/Apr-19-2018%2015-51-52.gif)

## Installation

Simply copy and paste TransitionClone.swift to your project, and add UIViewControllerTransitioningDelegate to the Class you're going to use.

Then add the two function above. Here I created an enum called transitionMode for the purpose to tell the code what state of transition we are in, if we’re going to Present than set it to “present”, if dismiss than set it to “dismiss”, simple as that.

    let transition = TransitionClone()
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        
        return transition
    }
    
Don't forget to set the starting frame and ending frame, for example:

    transition.startingFrame = CGRect(x: a.minX+15, y: a.minY+15, width: 375 / 414 * view.frame.width - 30, height: 408 / 736 * view.frame.height - 30)
    transition.destinationFrame = CGRect(x: 0, y: 0, width: view.frame.width, height: cell.myImage.frame.height * view.frame.width / cell.myImage.frame.width)
    
For the Pan Gesture, we’re going to use UIPanGestureRecognizer, which includes states like began, changed, ended, etc. It’ll give us the convenience to manipulate the animation ongoing percentage. You’ll get what I’m talking about very soon, but now let’s just add the above code to your destination view controller.

    import UIKit.UIGestureRecognizerSubclass
    class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if (self.state == UIGestureRecognizerState.began) { return }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began
        }
    }
    
Create the shrinking animation when draging on the Image, notice that we’re not going to use UIView.animate here because UIViewPropertyAnimator has the advantage to pause and resume the animation. You might be thinking why do we need to pause and resume the animation? Because we want the animation to interact with user’s finger! Which in other word to ““follow”” the finger.

    var animator = UIViewPropertyAnimator()
    func shrinkAnimation(){
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.view.layer.cornerRadius = 15
        })
        animator.startAnimation()
    }

Create a gesture recognizer and add to a UIView, I added on a button but it's ok to add it on the imageView

    let recognizer = InstantPanGestureRecognizer(target: self, action: #selector(panRecognizer))
    dismissButton.addGestureRecognizer(recognizer)

Create the panRecognizer, and it should work fine. Here’s what do the magic trick, by pausing the animation immediately after starting, we’re now in case .changed, we then track the vertical distance the finger drag from it’s initial place(if you want to track horizontal distance, just change translation.y ⇢ translation.x). Than add it to the current animation process(animator.fractionComplete). For a single tap recognition it’s even easier, there’s no need to add another tap recognizer. Just add an if statement in recognizer.state = ended see the code above :)

    var animationProgress: CGFloat = 0.0
    @objc func panRecognizer(recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: dismissButton)
        switch recognizer.state{
        case .began:
            shrinkAnimation()
            animationProgress = animator.fractionComplete
            // Pause after Start enable User to interact with the animation
            animator.pauseAnimation()
        case .changed:
            // translation.y = the distance finger drag on screen
            let fraction = translation.y / 100
            // fractionComplete the percentage of animation progress
            animator.fractionComplete = fraction + animationProgress
            // when animation progress > 99%, stop and start the dismiss transition
            if animator.fractionComplete > 0.99{
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
        case .ended:
            // when tap  on the screen animator.fractionComplete = 0
            if animator.fractionComplete == 0{
                animator.stopAnimation(true)
                dismiss(animated: true, completion: nil)
            }
            // when animator.fractionComplete < 99 % and release finger, automative rebounce to the initial state
            else{
                // rebounce effect
                animator.isReversed = true
                animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            }
        default:
            break
        }
    }

## Special Thanks

<div>Icons made by <a href="http://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
