//
//  SCGameBoardViewController.m
//  SharedCard
//
//  Created by JessieYong on 15/11/25.
//  Copyright © 2015年 JessieYong. All rights reserved.
//

#import "SCGameBoardViewController.h"
#import "SCMCManager.h"
#import "SharedCardProject-Swift.h"
#import "UIView+Toast.h"

@import MultipeerConnectivity;




@interface SCGameBoardViewController ()
@property(nonatomic, strong)Game *gameManager;
//@property(nonatomic, strong)NSMutableDictionary *playerAvatarDic;
@property(assign) NSInteger playerCount;
@end

@implementation SCGameBoardViewController


@synthesize player1;
@synthesize player2;


- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _gameManager = [Game Instance];
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
    NSLog(@"PEER STATUE CHANGE(From SCGameBoard):%@ is %ld\n", peerDisplayName, (long)state);
    if(state == MCSessionStateConnected) {
        Player *player = [[Player alloc] init];
        player.Id = [NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]];
        [_gameManager addPlayer:player];
        if (_playerCount == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [player1 setHighlighted:YES];
            });
//            [player1 setImage:[UIImage imageNamed:@"head_1_b"]];
//            [_playerAvatarDic setObject:[UIImage imageNamed:@"head_1_b"] forKey:player.Id];
        }
        if (_playerCount == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [player2 setHighlighted:YES];
            });
//            [player1 setImage:[UIImage imageNamed:@"head_2_b"]];
//            [_playerAvatarDic setObject:[UIImage imageNamed:@"head_2_b"] forKey:player.Id];
        }
        _playerCount++;
        //        if(_playerCount == 2) {
        //game begins
        CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
        style.imageSize = CGSizeMake(40, 40);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:nil duration:3 position:CSToastPositionCenter title:nil image:[UIImage imageNamed:@"head_1"] style:style completion:^(BOOL didTap) {
                [_gameManager startGame];
//                for (Player *player in [_gameManager getAllPlayers]) {
//                NSError *error = nil;
//                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:player];
//                [[SCMCManager shareInstance] sendData:data toPeer:player.Id error:error];
                }];
        });
        //    }
    }
    if(state == MCSessionStateNotConnected) {
        Player *player = [_gameManager getPlayer:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]]];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Oops!" message:[NSString stringWithFormat:@"%@ is offline. Game is stop!", player.Name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [self dismissViewControllerAnimated:YES completion:nil];
                                                                  [_gameManager removeAllPlayer];
                                                              }];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    /*
     
     UIImage *avatar = [_playerAvatarDic valueForKey:player.Id];
     //拿到原来的头像
     _playerCount--;
     [_gameManager removePlayer:[NSString stringWithFormat:@"%@", [[UIDevice currentDevice] identifierForVendor]]];
     }*/
}

- (void)beginAdvertiseing {
    [[SCMCManager shareInstance] setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [[SCMCManager shareInstance] advertiseSelf:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self beginAdvertiseing];
//    _mcManager = [[SCMCManager alloc] init];
//    [_mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
//    [_mcManager advertiseSelf:YES];

//    MCBrowserViewController *browserVC = [[MCBrowserViewController alloc] initWithServiceType:@"testtest" session:_session];
//    browserVC.delegate = self;
//    [self presentViewController:browserVC animated:YES completion:NULL];
    
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



- (IBAction)sendData:(id)sender {
    NSError *error = nil;
    NSString *str = @"123";
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    [[[SCMCManager shareInstance]  session] sendData:data toPeers:[_mcManager.session connectedPeers] withMode:MCSessionSendDataReliable error:&error];
}
@end
