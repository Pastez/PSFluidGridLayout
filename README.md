PSFluidGridLayout
=================

Fluid Grid Layout for UICollectionView

![image](https://raw.github.com/Pastez/PSFluidGridLayout/master/assets/preview.gif)


## Installation

Copy __```PSFluidGridLayout```__ directory into your project.

## How to use it

__Good place to see how to use it is demo project *(PSFluidGridLayoutDemo)*.__

1. Get reference, or create your collection view layout.

   ```
   // create
   PSFluidGridLayout *layout = [[PSFluidGridLayout alloc] init];
   UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds    collectionViewLayout:layout];
   
   // reference
   PSFluidGridLayout *layout = (id)self.collectionView.collectionViewLayout;
   ```
	
2. Set item constans dimension *(default is 250)*

	If layout direction is set to UICollectionViewScrollDirectionVertical this value controlls item width, or height if direction is set to UICollectionViewScrollDirectionHorizontal 
	
	```
	layout.constDimension = 250;
	```

3. Set layout ```direction``` *(default is UICollectionViewScrollDirectionVertical)*, and other not required properties.

	```
	layout.direction  = UICollectionViewScrollDirectionHorizontal;
	layout.itemInsets = UIEdgeInsetsMake(1, 1, 1, 1);
	```

4. Set ```PSFluidGridLayout``` delegate that implements PSFluidGridLayoutDelegate

	```
	layout.delegate = self	
	```

5. Create required delegate method that shold returns item height *(when direction is set to UICollectionViewScrollDirectionVertical)* or width *(when direction is UICollectionViewScrollDirectionHorizontal)*.

#### Other Options

 - sortPriority

   Defines whats more importent for sorting algorythm. If value is set to ```PSFluidGridLayoutSortPriorityColumnSize``` __(default)__ it trys to make columns *(vertical layout)* / rows *(horizontal layout)* equal size. When set to ```PSFluidGridLayoutSortPriorityIndexPaths``` items are displayed base on them indexPath.


 - topBottomFixed

   If you want to keep top and bottom of columns keep unfixed when offset in bigger or smaller than content size set ```topBottomFixed``` to __NO__.

## Demo app image assets

Demo app uses images form [Aleksandra Kwolek](http://www.kwolek.eu) website.

## License

The MIT License (MIT)

Copyright (c) 2013 Tomasz Kwolek

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
