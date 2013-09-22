//
//  FFViewController.m
//  FaceFriends
//
//  Created by Gerardo Martinez Gil on 1/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FFViewController.h"

@interface FFViewController() 
    @property (retain, nonatomic) CIDetector* faceDetector;
    -(void)sendToFaceCom;
@end

@implementation FFViewController
    @synthesize faceDetector;
    @synthesize staticImage;


    #pragma mark - View lifecycle
    - (void)viewDidLoad {
        [super viewDidLoad];
        // Do any additional setup after loading the view, typically from a nib.
        faceDetector = [[CIDetector detectorOfType:CIDetectorTypeFace 
                                          context:nil 
                                          options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]] retain];
        
        // flip image on y-axis to match coordinate system used by core image
        [staticImage setTransform:CGAffineTransformMakeScale(1, -1)];
        
        // flip the entire window to make everything right side up
        [[[[UIApplication sharedApplication] delegate] window] setTransform:CGAffineTransformMakeScale(1, -1)];
        
    }

    - (IBAction)detectFaces {
        CIImage* image = [CIImage imageWithCGImage:staticImage.image.CGImage];
        NSArray* features = [faceDetector featuresInImage:image];
        if(features != nil && features.count > 0) {
            //there is a face in the picture...
            [self sendToFaceCom];
            //show locally in the picture the eyes and mouth..
            for(CIFaceFeature* feature in features) {
                /////////////////FACE///////////////////
                // get the width of the face
                //CGFloat faceWidth = feature.bounds.size.width;
                // create a UIView using the bounds of the face
                UIView* faceView = [[UIView alloc] initWithFrame:feature.bounds];
                [faceView setBackgroundColor:[[UIColor yellowColor] colorWithAlphaComponent:0.4]];
                [[[[UIApplication sharedApplication] delegate] window] addSubview:faceView];
                [faceView release];
                
                /*
                 if(feature.hasLeftEyePosition) {
                 // create a UIView with a size based on the width of the face
                 UIView* leftEyeView = [[UIView alloc] initWithFrame:CGRectMake(feature.leftEyePosition.x-faceWidth*0.15, feature.leftEyePosition.y-faceWidth*0.15, faceWidth*0.3, faceWidth*0.3)];
                 // change the background color of the eye view
                 [leftEyeView setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
                 // set the position of the leftEyeView based on the face
                 [leftEyeView setCenter:feature.leftEyePosition];
                 // round the corners
                 //leftEyeView.layer.cornerRadius = faceWidth*0.15;
                 // add the view to the window
                 [[[[UIApplication sharedApplication] delegate] window] addSubview:leftEyeView];
                 }
                 */
                
                if(feature.hasLeftEyePosition) {
                    UIView* eye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
                    [eye setBackgroundColor:[[UIColor blueColor] colorWithAlphaComponent:0.2]];
                    [eye setCenter:feature.leftEyePosition];
                    [[[[UIApplication sharedApplication] delegate] window] addSubview:eye];
                    [eye release];
                }
                if(feature.hasRightEyePosition) {
                    UIView* eye = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
                    [eye setBackgroundColor:[[UIColor redColor] colorWithAlphaComponent:0.2]];
                    [eye setCenter:feature.rightEyePosition];
                    [[[[UIApplication sharedApplication] delegate] window] addSubview:eye];
                    [eye release];
                }
                
                if(feature.hasMouthPosition) {
                    UIView* mouth = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
                    [mouth setBackgroundColor:[[UIColor greenColor] colorWithAlphaComponent:0.2]];
                    [mouth setCenter:feature.mouthPosition];
                    [[[[UIApplication sharedApplication] delegate] window] addSubview:mouth];
                    [mouth release];
                }
            }
        }
    }

    
    -(void)sendToFaceCom {
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        NSData * imageData = UIImageJPEGRepresentation(staticImage.image, 90);
        NSURL * url = [NSURL URLWithString:@"http://api.face.com/faces/detect.json"];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request addPostValue:@"YOUR_API_KEY" forKey:@"api_key"];
        [request addPostValue:@"YOU_API_SECRET" forKey:@"api_secret"];
        [request addPostValue:@"all" forKey:@"attributes"];
        [request addData:imageData withFileName:@"image.jpg" andContentType:@"image/jpeg"
                  forKey:@"filename"];
        [request setDelegate:self];
        [request setDidFinishSelector:@selector(postFinished:)];
        [request setDidFailSelector:@selector(postFailed:)];
        [request startAsynchronous];
        [pool drain];
    }

    - (void)postFinished:(ASIHTTPRequest *)request {
        NSError *error = [request error];
        NSString *response = [request responseString];
        NSDictionary *feed = [NSJSONSerialization JSONObjectWithData:[request
                                                                      responseData]
                                                             options:kNilOptions
                                                               error:&error];
        NSLog(@"RETURN: %@", [feed allKeys]);
        NSLog(@"%@",response);
        /*
         "photos":[{
            "tags":[{
                "attributes":{
                    "glasses":{
                        "value":"false",
         
        NSArray *photos = [feed objectForKey:@"photos"];
        NSDictionary *tags = [photos objectAtIndex:0];
        [tags enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSLog(@"%@ = %@ is %@", key, obj, [obj class]);
        }];
        NSArray *values = [tags objectForKey:@"tags"];
        [values enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop){
            NSLog(@"%@ = %@ is %@", idx, object, [object class]);
        }];
        NSDictionary *attributes = [values objectAtIndex:0];
        [attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSLog(@"%@ = %@ is %@", key, obj, [obj class]);
        }];
        NSDictionary *newvalues  = [attributes objectForKey:@"attributes"];
        [newvalues enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSLog(@"%@ = %@ is %@", key, obj, [obj class]);
        }];
        NSDictionary *glasses = [newvalues objectForKey:@"glasses"];
        [glasses enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            NSLog(@"%@ = %@ is %@", key, obj, [obj class]);
        }];
        NSString *value = [glasses objectForKey:@"value"];
        NSLog(@"glasses = %@",value);
        */
        NSMutableString *message = [[[NSMutableString alloc] initWithString:@"glasses="] autorelease];
        NSString *glassesValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"glasses"] objectForKey:@"value"];
        [message appendString:glassesValue];
        [message appendString:@", smiling="];
        NSString *smilingValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"smiling"] objectForKey:@"value"];
        [message appendString:smilingValue];
        [message appendString:@", face="];
        NSString *faceValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"face"] objectForKey:@"value"];
        [message appendString:faceValue];
        [message appendString:@", gender="];
        NSString *genderValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"gender"] objectForKey:@"value"];
        [message appendString:genderValue];
        [message appendString:@", mood="];
        NSString *moodValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"mood"] objectForKey:@"value"];
        [message appendString:moodValue];
        [message appendString:@", lips="];
        NSString *lipsValue = [[[[[[[feed objectForKey:@"photos"] objectAtIndex:0] objectForKey:@"tags"] objectAtIndex:0] objectForKey:@"attributes"] objectForKey:@"lips"] objectForKey:@"value"];
        [message appendString:lipsValue];
        //show the response...
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:@"Face Info" 
                                  message:message 
                                  delegate:self 
                                  cancelButtonTitle:@"Cancel" 
                                  otherButtonTitles:@"OK", 
                                  nil];
        [alertView show];
        [alertView release];
    }

    - (void)postFailed:(ASIHTTPRequest *)request {
        NSError *error = [request error];
        NSLog(@"An error occured %d",[error code]);
    }

    - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
        if (buttonIndex == 0) {
            NSLog(@"Cancel");
        }
        else {            
            NSLog(@"Ok");
        }
    }
    

- (void)viewDidUnload
{
    [self setStaticImage:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dealloc {
    [staticImage release];
    [super dealloc];
}
@end
