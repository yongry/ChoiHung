//
//  SCGameBoard3ViewController.m
//  SharedCard
//
//  Created by Christina on 1/12/15.
//  Copyright © 2015 JessieYong. All rights reserved.
//

#import "SCGameBoard3ViewController.h"
#import "SCMCManager.h"
#import "SharedCardProject-Swift.h"
#import "UIView+Toast.h"
@import MultipeerConnectivity;



@interface SCGameBoard3ViewController ()
//@property(nonatomic, strong)NSMutableDictionary *playerAvatarDic;
@property(assign) NSInteger playerCount;



@end

@implementation SCGameBoard3ViewController

@synthesize player1;
@synthesize player2;
@synthesize player3;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _playerCount = 0;
//        _playerAvatarDic = [NSMutableDictionary dictionary];
    }
    [self addObserver];
    return  self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"SCMCDidChangeStateNotification"
                                               object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeObserver];
    [[SCMCManager shareInstance] advertiseSelf:NO];
}

- (void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    NSLog(@"PEER STATUE CHANGE(From SCGameBoard3):%@ is %ld\n", peerDisplayName, (long)state);
    if(state == MCSessionStateConnected) {
        Player *player = [[Player alloc] init];
        player.Id = peerID;
        [[Game Instance] addPlayer:player];
        if (_playerCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [player1 setHighlighted:YES];
            });
//            [_playerAvatarDic setObject:[UIImage imageNamed:@"head_1_b"] forKey:player.Id];
        }
        else if (_playerCount == 1) {
//            [player2 setImage:[UIImage imageNamed:@"head_2_b"]];
//            [_playerAvatarDic setObject:[UIImage imageNamed:@"head_2_b"] forKey:player.Id];
            dispatch_async(dispatch_get_main_queue(), ^{
                [player2 setHighlighted:YES];
            });
        }
        else if (_playerCount == 2) {
//            [player3 setImage:[UIImage imageNamed:@"head_3_b"]];
//            [_playerAvatarDic setObject:[UIImage imageNamed:@"head_3_b"] forKey:player.Id];
            dispatch_async(dispatch_get_main_queue(), ^{
                [player3 setHighlighted:YES];
            });
        }
        _playerCount++;
        //        if(_playerCount == 3) {
        //game begins
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.imageSize = CGSizeMake(40, 40);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:nil duration:3 position:CSToastPositionCenter title:nil image:[UIImage imageNamed:@"start-game"] style:style completion:nil];
            [[Game Instance] startGame];
            for (Player *player in [[Game Instance] getAllPlayers]) {
                NSError *error = nil;
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:player];
                [[SCMCManager shareInstance] sendData:data toPeer:player.Id error:error];
            }});
    }
    if(state == MCSessionStateNotConnected) {
        Player *player = [[Game Instance] getPlayer:peerID];
//         [_gameManager removePlayer:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"%@ is offline. Game is stop!", player.Name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                                  [[Game Instance] removeAllPlayer];
                                                              }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
        /*
 
        UIImage *avatar = [_playerAvatarDic valueForKey:player.Id];
        //拿到原来的头像
        _playerCount--;
       
    }*/
}

    

    

- (void)beginAdvertiseing {
    [[SCMCManager shareInstance] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[SCMCManager shareInstance] advertiseSelf:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self beginAdvertiseing];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
