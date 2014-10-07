//
//  PushAnimatedTransitioning.m
//  WhereNow
//
//  Created by Xiaoxue Han on 07/10/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "PushAnimatedTransitioning.h"

static NSTimeInterval const DEAnimatedTransitionDuration = 0.3f;

@implementation PushAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *container = [transitionContext containerView];
    
    if (self.reverse) {
        [container insertSubview:toViewController.view belowSubview:fromViewController.view];
        toViewController.view.transform = CGAffineTransformMakeTranslation(-fromViewController.view.frame.size.width, 0);
    }
    else {
        toViewController.view.transform = CGAffineTransformMakeTranslation(fromViewController.view.frame.size.width, 0);
        [container addSubview:toViewController.view];
    }
    
    [UIView animateKeyframesWithDuration:DEAnimatedTransitionDuration delay:0 options:0 animations:^{
        if (self.reverse) {
            fromViewController.view.transform = CGAffineTransformMakeTranslation(fromViewController.view.frame.size.width, 0);
            toViewController.view.transform = CGAffineTransformIdentity;
        }
        else {
            toViewController.view.transform = CGAffineTransformIdentity;
            fromViewController.view.transform = CGAffineTransformMakeTranslation(-fromViewController.view.frame.size.width/3, 0);
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return DEAnimatedTransitionDuration;
}

@end
