//
//  SCIpadCongController.h
//  SharedCard
//
//  Created by JessieYong on 15/12/12.
//  Copyright © 2015年 JessieYong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCIpadCongController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *winIcon;
@property (nonatomic, strong) UIImage *winnerIcon;
- (IBAction)playAgain:(id)sender;

@end
