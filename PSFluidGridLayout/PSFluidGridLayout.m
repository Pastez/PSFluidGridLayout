//
//  PSSmothScrollLayout.m
//  Gallery
//
//  Created by Tomasz Kwolek on 21.11.2013.
//The MIT License (MIT)
//
//Copyright (c) 2013 Tomasz Kwolek
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


#import "PSFluidGridLayout.h"

@interface PSFluidLayoutAttribute : UICollectionViewLayoutAttributes

@property (readwrite,nonatomic) CGRect initialFrame;

@end

@implementation PSFluidLayoutAttribute

//

@end

@interface PSFluidGridLayout()

@property (strong,nonatomic) NSDictionary *attributesForIndexPath;
@property (strong,nonatomic) NSArray *attributes;
@property (strong,nonatomic) NSArray *attributesForColumn;
@property (strong,nonatomic) NSArray *columnsHeights;

@property (readwrite,nonatomic) NSInteger itemCount;
@property (readwrite,nonatomic) NSInteger lastItemCount;
@property (readwrite,nonatomic) CGSize lastSize;
@property (readwrite,nonatomic) CGFloat lastScrollPrc;

@end

@implementation PSFluidGridLayout

- (id)init {
    if((self = [super init]))
        [self initialize];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder]))
        [self initialize];
    
    return self;
}

- (void) initialize {
    // defaults
    self.itemCount              = 0;
    self.lastItemCount          = 0;
    self.lastScrollPrc          = 0;
    
    self.constDimension         = 250;
    self.topBottomFixed         = YES;
    self.direction              = UICollectionViewScrollDirectionVertical;
    self.itemInsets             = UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f);
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    if (([self.collectionView numberOfItemsInSection:0] == _lastItemCount || [self.collectionView numberOfItemsInSection:0] == 0 )
        && (_lastSize.width == self.collectionView.bounds.size.width && _lastSize.height == self.collectionView.bounds.size.height)) {
        return;
    }
    
    _lastItemCount = [self.collectionView numberOfItemsInSection:0];
    _lastSize = self.collectionView.bounds.size;
    
    // variable naming convention for UICollectionViewScrollDirectionVertical
    CGFloat contentWidth;
    CGFloat itemWidth = _constDimension;
    if( _direction == UICollectionViewScrollDirectionVertical )
    {
        contentWidth = CGRectGetWidth(self.collectionView.frame);
        contentWidth -= self.collectionView.contentInset.left + self.collectionView.contentInset.right;
        itemWidth += _itemInsets.left + _itemInsets.right;
    }
    else
    {
        contentWidth = CGRectGetHeight(self.collectionView.frame);
        contentWidth -= self.collectionView.contentInset.top + self.collectionView.contentInset.bottom + 20;
        itemWidth += _itemInsets.top + _itemInsets.bottom;
    }
    
    NSInteger columnCount = floorf( contentWidth / itemWidth );
    // create tmp colums
    NSMutableArray *columns = [NSMutableArray arrayWithCapacity:columnCount];
    NSMutableArray *columnsHeights = [NSMutableArray arrayWithCapacity:columnCount];
    for (int c = 0; c < columnCount; c++)
    {
        columns[c]          = [NSMutableArray array];
        columnsHeights[c]   = @0;
    }
    
    /*
     * Put index paths to right colums
     */
    NSInteger sectionIdx;
    NSInteger itemIdx;
    self.itemCount = 0;
    
    if (_sortPriority == PSFluidGridLayoutSortPriorityColumnSize)
    {
        /*
         * PSFluidGridLayoutSortPriorityColumnSize
         * Sorting items by size
         */
        NSMutableArray *indexPathToDimension = [NSMutableArray array];
        for (sectionIdx = 0; sectionIdx < [self.collectionView numberOfSections]; sectionIdx++) {
            for (itemIdx = 0; itemIdx < [self.collectionView numberOfItemsInSection:sectionIdx]; itemIdx++)
            {
                NSIndexPath *itemIndexPath  = [NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx];
                CGFloat itemHeight          = [_delegate fluidLayout:self variableDimensionForItemAtIndexPath:itemIndexPath];
                [indexPathToDimension addObject:@{@"indexPath" : itemIndexPath,
                                                  @"idx" : [NSNumber numberWithInteger:_itemCount],
                                                  @"height" : [NSNumber numberWithFloat:itemHeight]}];
                _itemCount++;
            }
        }
        
        [indexPathToDimension sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CGFloat obj1Height = ((NSNumber*)obj1[@"height"]).floatValue;
            CGFloat obj2Height = ((NSNumber*)obj2[@"height"]).floatValue;
            if (obj1Height > obj2Height) {
                return (NSComparisonResult)NSOrderedDescending;
            }
            
            if (obj1Height < obj2Height) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        for (itemIdx = 0; itemIdx < indexPathToDimension.count; itemIdx++)
        {
            NSInteger destinationColumn = 0;
            CGFloat destinationColumnHeight = MAXFLOAT;
            for (NSInteger columnIdx = 0; columnIdx < columnsHeights.count; columnIdx++) {
                if (destinationColumnHeight > ((NSNumber*)columnsHeights[columnIdx]).floatValue)
                {
                    destinationColumn = columnIdx;
                    destinationColumnHeight = ((NSNumber*)columnsHeights[columnIdx]).floatValue;
                }
            }
            
            NSIndexPath *itemIndexPath = indexPathToDimension[itemIdx][@"indexPath"];
            
            CGFloat itemHeight = [_delegate fluidLayout:self variableDimensionForItemAtIndexPath:itemIndexPath];
            CGFloat columnHeight = ((NSNumber*)columnsHeights[destinationColumn]).floatValue;
            columnsHeights[destinationColumn] = [NSNumber numberWithFloat:itemHeight + columnHeight];
            [((NSMutableArray*)columns[destinationColumn]) addObject:itemIndexPath];
        }
        
        /*
         * Sorts items in colums
         */
        
        for (NSInteger columnIdx = 0; columnIdx < columns.count; columnIdx++ )
        {
            NSMutableArray *column = columns[ columnIdx ];
            [column sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                NSIndexPath *obj1IndexPath = obj1;
                NSIndexPath *obj2IndexPath = obj2;
                
                if( obj1IndexPath.section > obj2IndexPath.section ) return NSOrderedDescending; else
                    if (obj1IndexPath.section < obj2IndexPath.section) return NSOrderedAscending; else
                    {
                        if (obj1IndexPath.row > obj2IndexPath.row) return NSOrderedDescending; else
                            if (obj1IndexPath.row < obj1IndexPath.row) return NSOrderedAscending;
                    }
                return NSOrderedSame;
            }];
        }
        
    }
    else if (_sortPriority == PSFluidGridLayoutSortPriorityIndexPaths)
    {
        /*
         * PSFluidGridLayoutSortPriorityIndexPaths
         * Sorting items by indexPath.row
         */
        NSInteger destinationColumn = 0;
        for (sectionIdx = 0; sectionIdx < [self.collectionView numberOfSections]; sectionIdx++) {
            for (itemIdx = 0; itemIdx < [self.collectionView numberOfItemsInSection:sectionIdx]; itemIdx++)
            {
                NSIndexPath *itemIndexPath  = [NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx];
                [((NSMutableArray*)columns[destinationColumn]) addObject:itemIndexPath];
                destinationColumn++;
                if (destinationColumn == columnCount) {
                    destinationColumn = 0;
                }
            }
        }
        
    }
    
    /*
     *
     * Assign attributes to items
     *
     */
    columnsHeights = [NSMutableArray arrayWithCapacity:columnCount];
    
    NSMutableDictionary *attributesForIndexPath = [NSMutableDictionary dictionary];
    NSMutableArray *attributesForColumn = [NSMutableArray array];
    for (int i = 0; i < columnCount; i++) {
        [attributesForColumn addObject:[NSMutableArray array]];
    }
    NSMutableArray *attributes = [NSMutableArray array];
    for (NSInteger columnIdx = 0; columnIdx < columns.count; columnIdx++) {
        NSArray *itemsIndexPaths = columns[columnIdx];
        CGFloat dx = 0;
        CGFloat dy = 0;
        
        if (_direction == UICollectionViewScrollDirectionVertical) {
            dx += columnIdx * (_constDimension + _itemInsets.left + _itemInsets.right );
        }else
        {
            dy += columnIdx * (_constDimension + _itemInsets.top + _itemInsets.bottom );
        }
        
        //NSMutableSet *itemsIndexPathsSet = [NSMutableSet setWithArray:itemsIndexPaths];
        for(itemIdx = 0; itemIdx < itemsIndexPaths.count; itemIdx++)
        {
            NSIndexPath *itemIndexPath = itemsIndexPaths[itemIdx];
            
            CGRect itemFrame = CGRectMake(dx + _itemInsets.left, dy + _itemInsets.top, 0, 0);
            if (_direction == UICollectionViewScrollDirectionVertical)
            {
                itemFrame.size.width = _constDimension;
                itemFrame.size.height = [_delegate fluidLayout:self variableDimensionForItemAtIndexPath:itemIndexPath];
                dy += itemFrame.size.height + _itemInsets.bottom;
                
                columnsHeights[columnIdx] = [NSNumber numberWithFloat:dy];
            }
            else
            {
                itemFrame.size.width = [_delegate fluidLayout:self variableDimensionForItemAtIndexPath:itemIndexPath];
                itemFrame.size.height = _constDimension;
                dx += itemFrame.size.width + _itemInsets.right;
                
                columnsHeights[columnIdx] = [NSNumber numberWithFloat:dx];
            }
            
            //NSLog(@"%d(%d,%d) %@",columnIdx,itemIndexPath.row,itemIndexPath.section,CGRectCreateDictionaryRepresentation(itemFrame));
            
            PSFluidLayoutAttribute *itemAttributes = [PSFluidLayoutAttribute layoutAttributesForCellWithIndexPath:itemIndexPath];
            itemAttributes.initialFrame = itemFrame;
            itemAttributes.frame = itemFrame;
            
            [attributesForIndexPath setObject:itemAttributes forKey:itemIndexPath];
            [attributes addObject:itemAttributes];
            [attributesForColumn[columnIdx] addObject:itemAttributes];
        }
    }
    self.attributesForIndexPath = attributesForIndexPath;
    self.attributesForColumn = attributesForColumn;
    self.attributes = attributes;
    self.columnsHeights = columnsHeights;
    
    
}

- (void)onCollectionViewScroll:(CGFloat)prc
{
    for (int columnIdx = 0; columnIdx < _attributesForColumn.count; columnIdx++) {
        
        CGFloat offset;
        
        if (_direction == UICollectionViewScrollDirectionVertical) {
            offset = [self collectionViewContentSize].height - ((NSNumber*)_columnsHeights[columnIdx]).floatValue;
        }
        else
        {
            offset = [self collectionViewContentSize].width - ((NSNumber*)_columnsHeights[columnIdx]).floatValue;
        }
        
        for (PSFluidLayoutAttribute *attribute in _attributesForColumn[columnIdx])
        {
            
            CGRect newFrame = attribute.initialFrame;
            if (_direction == UICollectionViewScrollDirectionVertical) {
                newFrame.origin.y += offset * prc;
            }else
            {
                newFrame.origin.x += offset * prc;
            }
            
            attribute.frame = newFrame;
            
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:attribute.indexPath];
            cell.frame = attribute.frame;
        }
    }
    self.lastScrollPrc = prc;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    UICollectionViewLayoutAttributes *atributes = [_attributesForIndexPath objectForKey:path];
	return atributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
	NSMutableArray *attributes = [NSMutableArray array];
    
	for (UICollectionViewLayoutAttributes *attribute in _attributes) {
        if (CGRectIntersectsRect(rect, attribute.frame)) {
            [attributes addObject:attribute];
        }
    }
    
	return [attributes copy];
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound
{
    if ([self.collectionView numberOfItemsInSection:0] == 0) return NO;
    UIScrollView *scrollView = self.collectionView;
    CGFloat offset;
    CGFloat prc;
    if (_direction == UICollectionViewScrollDirectionVertical) {
        offset = scrollView.contentOffset.y + self.collectionView.contentInset.top;
        prc = offset / ([self collectionViewContentSize].height - CGRectGetHeight(self.collectionView.frame)
                        + self.collectionView.contentInset.bottom + self.collectionView.contentInset.top);
    }
    else
    {
        offset = scrollView.contentOffset.x + self.collectionView.contentInset.left;
        prc = offset / ([self collectionViewContentSize].width - CGRectGetWidth(self.collectionView.frame)
                        + self.collectionView.contentInset.right + self.collectionView.contentInset.left);
    }
    
    if (_topBottomFixed && (prc < 0 || prc > 1 )) {
        prc = prc < 0 ? 0 : 1;
    }
    
    [self onCollectionViewScroll:prc];
    
    return YES;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = [super collectionViewContentSize];
    
    CGFloat minValue = MAXFLOAT;
    for (NSInteger columnIdx = 0; columnIdx < _columnsHeights.count; columnIdx++) {
        CGFloat h = ((NSNumber*)_columnsHeights[columnIdx]).floatValue;
        if (h < minValue) {
            minValue = h;
        }
    }
    
    if (_direction == UICollectionViewScrollDirectionVertical) {
        size.width = _attributesForColumn.count * (_constDimension + _itemInsets.left + _itemInsets.right );
        size.height = minValue;;
    }
    else
    {
        size.width = minValue;
        size.height = _attributesForColumn.count * (_constDimension + _itemInsets.top + _itemInsets.bottom );
    }
    return size;
}

@end
