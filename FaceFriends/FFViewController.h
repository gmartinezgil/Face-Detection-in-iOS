//
//  FFViewController.h
//  FaceFriends
//
//  Created by Gerardo Martinez Gil on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "ASIFormDataRequest.h"

@interface FFViewController : UIViewController<UIAlertViewDelegate> {
    CIDetector* faceDetector;
}
@property (retain, nonatomic) IBOutlet UIImageView *staticImage;
- (IBAction)detectFaces;

@end
