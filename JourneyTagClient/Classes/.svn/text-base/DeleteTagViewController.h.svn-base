//
//  DeleteTagViewController.h
//  JourneyTag
//
//  Created by Ben Ford on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTTagService.h"

@interface DeleteTagViewController : UIViewController {
    NSString *myTagKey;
    JTTagService *tagService;
    
    id myTarget;
    SEL myAction;
    
    IBOutlet UITextField *verifyText;
}

- (id)initWithTagKey:(NSString*)tagKey target:(id)target action:(SEL)action;
- (IBAction) deleteTag:(id)sender;
@end