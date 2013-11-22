//
//  PSViewController.h
//  PSFluidGridLayoutDemo
//
//  Created by Tomasz Kwolek on 22.11.2013.
//  Copyright (c) 2013 Tomasz Kwolek Pastez.com 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSViewController : UIViewController

@property (assign,nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)addItem:(id)sender;
- (IBAction)removeItem:(id)sender;

@end
