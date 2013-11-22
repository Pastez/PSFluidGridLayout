//
//  PSSmothScrollLayout.h
//  Gallery
//
//  Created by Tomasz Kwolek on 21.11.2013.
//  Copyright (c) 2013 Tomasz Kwolek Pastez.com 2013. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSFluidGridLayout;

@protocol PSFluidGridLayoutDelegate <NSObject>

- (CGFloat)fluidLayout:(PSFluidGridLayout*)layout variableDimensionForItemAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface PSFluidGridLayout : UICollectionViewLayout

@property (assign,nonatomic) IBOutlet id<PSFluidGridLayoutDelegate> delegate;
@property (assign,nonatomic) UICollectionViewScrollDirection direction;
@property (readwrite,nonatomic) UIEdgeInsets itemInsets;
@property (readwrite,nonatomic) CGFloat constDimension;

@end
