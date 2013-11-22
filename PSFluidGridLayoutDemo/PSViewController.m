//
//  PSViewController.m
//  PSFluidGridLayoutDemo
//
//  Created by Tomasz Kwolek on 22.11.2013.
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

#import "PSViewController.h"
#import "PSFluidGridLayout.h"
#import "PSCollectionViewCell.h"

#define ITEM_CONST_DIMENSION        250.0
#define SCROLL_DIRECTION            UICollectionViewScrollDirectionVertical
//#define SCROLL_DIRECTION            UICollectionViewScrollDirectionHorizontal

@interface PSViewController () <PSFluidGridLayoutDelegate,UICollectionViewDataSource>

@property (assign,nonatomic) PSFluidGridLayout *layout;

@property (copy,nonatomic) NSArray *imagesPaths;
// used as data source for collection view
@property (strong,nonatomic) NSArray *images;

@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 6, 50, 0);
    
    self.layout = (id)self.collectionView.collectionViewLayout;
    self.layout.constDimension = ITEM_CONST_DIMENSION;
    self.layout.direction = SCROLL_DIRECTION;
    self.layout.itemInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    self.layout.delegate = self;
    
    _images = [NSArray array];
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"1" ofType:@"jpg"] stringByDeletingLastPathComponent];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error;
    NSArray *dirContent = [fm contentsOfDirectoryAtPath:path error:&error];
    if (!error) {
        NSMutableArray *images = [NSMutableArray array];
        for (NSString *filename in dirContent) {
            if ([[filename pathExtension] isEqualToString:@"jpg"]) {
                [images addObject:[NSString stringWithFormat:@"%@/%@",path,filename]];
            }
        }
        self.imagesPaths = images;
        self.images = images;
        [self.collectionView reloadData];
    }else
    {
        NSLog(@"error while listing directory: %@",error);
    }
}

#pragma mark - Actions

- (void)addItem:(id)sender
{
    NSMutableArray *tmpImages = [NSMutableArray arrayWithArray:_images];
    [tmpImages addObject:[_imagesPaths objectAtIndex:drand48() * (_imagesPaths.count-1)]];
    self.images = tmpImages;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_images.count-1 inSection:0]]];
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)removeItem:(id)sender
{
    if( _images.count <= 1 ) return;
    NSMutableArray *tmpImages = [NSMutableArray arrayWithArray:_images];
    NSInteger index = drand48() * (_images.count - 1);
    [tmpImages removeObjectAtIndex:index];
    self.images = tmpImages;
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    } completion:^(BOOL finished) {
        //
    }];
}

#pragma mark - PSFluidGridLayout Delegate

- (CGFloat)fluidLayout:(PSFluidGridLayout *)layout variableDimensionForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIImage *image = [UIImage imageWithContentsOfFile:_images[indexPath.row]];
    float ratio;
    if (SCROLL_DIRECTION == UICollectionViewScrollDirectionVertical) {
        ratio = image.size.width / image.size.height;
    }else
    {
        ratio = image.size.height / image.size.width;
    }
    return ITEM_CONST_DIMENSION / ratio;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PSCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *image = [UIImage imageWithContentsOfFile:_images[indexPath.row]];
    cell.imageView.image = image;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _images.count;
}

@end
