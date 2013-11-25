//
//  PSSmothScrollLayout.h
//  Gallery
//
//  Created by Tomasz Kwolek on 21.11.2013.
//  Copyright (c) 2013 Tomasz Kwolek Pastez.com 2013. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <UIKit/UIKit.h>

@class PSFluidGridLayout;

@protocol PSFluidGridLayoutDelegate <NSObject>

- (CGFloat)fluidLayout:(PSFluidGridLayout*)layout variableDimensionForItemAtIndexPath:(NSIndexPath*)indexPath;

@end

@interface PSFluidGridLayout : UICollectionViewLayout

/** Sets delegate for layout. Delegate object must conform to PSFluidGridLayoutDelegate protocol */
@property (assign,nonatomic) IBOutlet id<PSFluidGridLayoutDelegate> delegate;

/** The scroll direction of the grid. */
@property (assign,nonatomic) UICollectionViewScrollDirection direction;

/** The item insets. */
@property (readwrite,nonatomic) UIEdgeInsets itemInsets;

/** Constant dimension of items. If layout direction is set to UICollectionViewScrollDirectionVertical
 * this value controlls item width, or height if direction is set to UICollectionViewScrollDirectionHorizontal
 */
@property (readwrite,nonatomic) CGFloat constDimension;

/** Keeps beging and ending of each column fixed to the same position if
 content offset is smaller on bigger then content size */
@property (readwrite,nonatomic) BOOL topBottomFixed;

@end
