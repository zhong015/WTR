//
//  WTRCollectionLayout.m
//  asda
//
//  Created by wfz on 16/5/12.
//  Copyright © 2016年 wfz. All rights reserved.
//

#import "WTRCollectionLayout.h"
#import "WTRBaseDefine.h"

@implementation WTRCellFakeView
- (instancetype)initWithCell:(UICollectionViewCell *)cell{
    self = [super initWithFrame:cell.frame];
    if (self) {
        self.cell = cell;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0;
        self.layer.shadowRadius = 5.0;
        self.layer.shouldRasterize = false;
        
        self.cellFakeImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.cellFakeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.cellFakeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      
        self.cellFakeImageView.image = [self getCellImage];
        
        [self addSubview:self.cellFakeImageView];
    }
    return self;
}
- (void)pushFowardView{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{

        self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        
        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @(0);
        shadowAnimation.toValue = @(0.7);
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"applyShadow"];
    } completion:nil];
}

- (void)pushBackViewFrame:(CGRect)cellFrame isChaRu:(BOOL)isc completion:(void(^)(void))completion{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        self.transform=CGAffineTransformIdentity;
        self.frame = cellFrame;
        if (isc) {
            self.transform = CGAffineTransformMakeScale(0.4, 0.4);
        }

        CABasicAnimation *shadowAnimation = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
        shadowAnimation.fromValue = @(0.7);
        shadowAnimation.toValue = @(0);
        shadowAnimation.removedOnCompletion = NO;
        shadowAnimation.fillMode = kCAFillModeForwards;
        [self.layer addAnimation:shadowAnimation forKey:@"removeShadow"];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}
- (UIImage *)getCellImage{
    UIGraphicsBeginImageContextWithOptions(_cell.bounds.size, NO, [UIScreen mainScreen].scale * 2);
    [_cell drawViewHierarchyInRect:_cell.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@interface WTRCollectionLayout () <UIGestureRecognizerDelegate>

@property(nonatomic,strong)WTRCellFakeView *fakeView;

@property(nonatomic,strong)UILongPressGestureRecognizer *longges;
@property(nonatomic,strong)NSIndexPath *savedcurintNearIndex;

@end

@implementation WTRCollectionLayout
{
    UIPanGestureRecognizer *_panGesture;
    BOOL isMoving;
    
    NSIndexPath *_curintNearIndex;
    
    CGFloat XJianGe;
    CGPoint curPanlocation;
    
    CADisplayLink *_displayLink;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self loadchushihua];
    }
    return self;
}
-(id)init
{
    self=[super init];
    if (self) {
        [self loadchushihua];
    }
    return self;
}
-(void)loadchushihua
{
    self.ChaRuBili=0.9;
    self.HuDongD=10;
    
    self.totalSpeedLJ=100;

    self.isCanLongPressBigin=YES;
    self.isCanPanMoveBigin=NO;
}
-(void)prepareLayout
{
    [super prepareLayout];
    if (!self.longges) {
        self.longges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longgesclick:)];
        self.longges.delegate = self;
        NSArray *gestures = [self.collectionView gestureRecognizers];
        __WEAKSelf
        [gestures enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [(UILongPressGestureRecognizer *)obj requireGestureRecognizerToFail:weakSelf.longges];
            }
        }];
        [self.collectionView addGestureRecognizer:self.longges];
        
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
        _panGesture.maximumNumberOfTouches = 1;
        [self.collectionView addGestureRecognizer:_panGesture];
    }
}
//view 的superview 列表里 是否有 class 类
-(BOOL)isView:(UIView *)view SuperviewContentClass:(Class)class
{
    UIView *csuperview=view.superview;
    while (csuperview&&![csuperview isKindOfClass:[UIWindow class]]) {
        if ([csuperview isKindOfClass:class]) {
            return YES;
        }
        csuperview=csuperview.superview;
    }
    return NO;
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![self isView:touch.view SuperviewContentClass:[UICollectionViewCell class]]) {
        return NO;
    }

//    if ((gestureRecognizer==_longges||gestureRecognizer==_panGesture)&&touch.view==self.collectionView) {
//        return NO;
//    }

    if (gestureRecognizer==_longges) {
        if (self.isCanLongPressBigin==NO) {
            return NO;
        }
        CGPoint location = [touch locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
        if (indexPath) {
            if ([_delegate respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
                BOOL canMove = [_delegate collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
                if (!canMove) {
                    return NO;
                }
            }
        }
    }
    if (gestureRecognizer==_panGesture) {
        if (!isMoving) {
            CGPoint location = [touch locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (indexPath) {
                if ([_delegate respondsToSelector:@selector(collectionView:canMoveItemAtIndexPath:)]) {
                    BOOL canMove = [_delegate collectionView:self.collectionView canMoveItemAtIndexPath:indexPath];
                    if (!canMove) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.isCanPanMoveBigin&&gestureRecognizer==_panGesture) {
        if (!isMoving) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (gestureRecognizer==_longges) {
        if (otherGestureRecognizer==_panGesture) {
            return YES;
        }
    }
    if (gestureRecognizer==_panGesture) {
        if (otherGestureRecognizer==self.collectionView.panGestureRecognizer) {
            if (self.isCanPanMoveBigin) {
                return NO;
            }
            return YES;
        }
    }
    return NO;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    if (attributesArray == nil||!isMoving) {
        return attributesArray;
    }
    [attributesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *layoutAttribute = obj;
        if (layoutAttribute.representedElementCategory==UICollectionElementCategoryCell&&[layoutAttribute.indexPath isEqual:self.fakeView.indexPath]){
            layoutAttribute.alpha = 0.36;  //修改 要移动的原cell
        }
    }];
    return attributesArray;
}

-(void)longgesclick:(UILongPressGestureRecognizer *)longges
{
    if (longges.state==UIGestureRecognizerStateBegan) {
        CGPoint location = [longges locationInView:self.collectionView];
        [self beginmoving:location afterDelay:0.15];
    }else if (longges.state==UIGestureRecognizerStateChanged) {
        
    }else if (longges.state==UIGestureRecognizerStateEnded) {
        [self endMoving];
    }else if (longges.state==UIGestureRecognizerStateCancelled) {
        [self endMoving];
    }
    else if (longges.state==UIGestureRecognizerStateFailed){
        NSLog(@"UIGestureRecognizerStateFailed");
    }
}
-(void)beginmoving:(CGPoint)location afterDelay:(NSTimeInterval)delay
{
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if (!indexPath) {
        return;
    }
    if (_delegate&&[_delegate respondsToSelector:@selector(collectionView:willEditingAtIndexPath:)]) {
        [_delegate collectionView:self.collectionView willEditingAtIndexPath:indexPath];
    }
    [self performSelector:@selector(beginmovingWithindexPath:) withObject:indexPath afterDelay:delay];
}
-(void)beginmovingWithindexPath:(NSIndexPath *)indexPath
{
    isMoving=YES;
    UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.fakeView) {
        [self.fakeView removeFromSuperview];
    }
    self.fakeView = [[WTRCellFakeView alloc] initWithCell:currentCell];
    self.fakeView.indexPath = indexPath;
    [self.collectionView addSubview:self.fakeView];
    [self.fakeView pushFowardView];
    [self updataXJianGe];
    [self invalidateLayout];
}
-(void)updataXJianGe
{
    UICollectionViewCell *currentCell1 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.fakeView.indexPath.section]];
    UICollectionViewCell *currentCell2 = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:self.fakeView.indexPath.section]];
    if (currentCell1&&currentCell2) {
        XJianGe=ABS(currentCell2.center.x-currentCell1.center.x)-self.itemSize.width;
        if (XJianGe>self.itemSize.width) {
            XJianGe=5.0;
        }
    }
}
#pragma mark 调整collectionView 暂时只是UICollectionViewScrollDirectionVertical管用
-(void)tiaozhengcollectionView
{
    if (!isMoving) {
        [self invalidateDisplayLink];
        return;
    }
    if (self.scrollDirection==UICollectionViewScrollDirectionVertical) {
        if (curPanlocation.y-self.collectionView.contentOffset.y-self.collectionView.contentInset.top<self.itemSize.height/3.0) {
            if (self.collectionView.contentOffset.y+self.collectionView.contentInset.top>0.1) {
                CGFloat yy=self.collectionView.contentOffset.y-self.HuDongD;
                if (yy<-self.collectionView.contentInset.top) {
                    yy=-self.collectionView.contentInset.top;
                }
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,yy) animated:NO];
                [self setUpDisplayLink];
                return;
            }
            
        }else if (curPanlocation.y-self.collectionView.contentOffset.y-self.collectionView.frame.size.height+self.collectionView.contentInset.bottom>-self.itemSize.height/3.0)
        {
            if (self.collectionView.contentOffset.y<self.collectionView.contentSize.height+self.collectionView.contentInset.bottom-self.collectionView.frame.size.height) {
                CGFloat yy=self.collectionView.contentOffset.y+self.HuDongD;
                if (yy>self.collectionView.contentSize.height+self.collectionView.contentInset.bottom-self.collectionView.frame.size.height) {
                    yy=self.collectionView.contentSize.height+self.collectionView.contentInset.bottom-self.collectionView.frame.size.height;
                }
                [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentOffset.x,yy) animated:NO];
                [self setUpDisplayLink];
                return;
            }
        }
    }
    
    [self invalidateDisplayLink];
}
- (void)setUpDisplayLink{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tiaozhengcollectionView)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)invalidateDisplayLink{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    if (self.isCanPanMoveBigin&&!isMoving&&pan.state==UIGestureRecognizerStateBegan) {
        CGPoint location = [pan locationInView:self.collectionView];
        [self beginmoving:location afterDelay:0.01];
    }
    if (isMoving&&pan.state==UIGestureRecognizerStateChanged) {
        CGPoint location = [pan locationInView:self.collectionView];
        curPanlocation=location;
        self.fakeView.center=location;
        
        CGPoint speed = [pan velocityInView:self.collectionView];
        CGFloat totalSpeed = sqrtf(speed.x*speed.x+speed.y*speed.y);
        if (totalSpeed<self.totalSpeedLJ) {
            [self tiaozhengcollectionView];

            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:location];
            if (!indexPath) {
                indexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(location.x-XJianGe/2.0, location.y)];
                if (!indexPath) {
                    indexPath = [self.collectionView indexPathForItemAtPoint:CGPointMake(location.x+XJianGe/2.0, location.y)];
                }
            }
            BOOL islast=[self isLastJH:location];
            if (islast||!indexPath||[indexPath isEqual:self.fakeView.indexPath]) {
                [self clearlastNearIndexIsEndMoving:NO];
                return;
            }

            if (indexPath.section!=self.fakeView.indexPath.section) {
                return;
            }

            if ([_delegate respondsToSelector:@selector(collectionView:canMoveItemToIndexPath:)]) {
                if (![_delegate collectionView:self.collectionView canMoveItemToIndexPath:indexPath]){
                    return;
                }
            }
            
            UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:indexPath];
            if (!currentCell) {
                return;
            }

            BOOL iscom=NO;
            if (ABS(location.x-currentCell.center.x)<self.itemSize.width*self.ChaRuBili/2.0&&ABS(location.y-currentCell.center.y)<self.itemSize.height*self.ChaRuBili/2.0) {
                if (_curintNearIndex&&[_curintNearIndex isEqual:indexPath]) {
                    return;
                }
                if ([_delegate respondsToSelector:@selector(collectionView:canCombineItemFromIndexPath:toIndexPath:)]) {
                    if ([_delegate collectionView:self.collectionView canCombineItemFromIndexPath:self.fakeView.indexPath toIndexPath:indexPath]) {

                        [self clearlastNearIndexIsEndMoving:NO];
                        _curintNearIndex=indexPath;
                        NSLog(@"插入%d",(int)_curintNearIndex.row);
                        [UIView animateWithDuration:0.3 animations:^{
                            currentCell.transform=CGAffineTransformMakeScale(1.2, 1.2);
                            self.fakeView.transform = CGAffineTransformMakeScale(0.9, 0.9);
                        }completion:nil];
                        [self invalidateLayout];
                        iscom=YES;
                    }
                }
            }
            if (!iscom&&(ABS(location.x-currentCell.center.x)<(self.itemSize.width+self.minimumInteritemSpacing)/2.0||ABS(location.y-currentCell.center.y)<(self.itemSize.height+self.minimumLineSpacing)/2.0))
            {
                [self clearlastNearIndexIsEndMoving:NO];
                NSLog(@"交换,%d",(int)indexPath.row);
                NSIndexPath *ylasindex=self.fakeView.indexPath;
                self.fakeView.indexPath=indexPath;
                __WEAKSelf
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView moveItemAtIndexPath:ylasindex toIndexPath:indexPath];
                } completion:^(BOOL finished) {
                    if ([weakSelf.delegate respondsToSelector:@selector(collectionView:didmoveItemAtIndexPath:toIndexPath:)]) {
                        [weakSelf.delegate collectionView:self.collectionView didmoveItemAtIndexPath:ylasindex toIndexPath:indexPath];
                    }
                }];
            }
            
        }
    }else if (self.isCanPanMoveBigin&&isMoving&&pan.state==UIGestureRecognizerStateEnded) {
        [self endMoving];
    }else if (self.isCanPanMoveBigin&&isMoving&&pan.state==UIGestureRecognizerStateCancelled) {
        [self endMoving];
    }
}
-(BOOL)isLastJH:(CGPoint )lopoint //是否是交换最后一个
{
    BOOL islase=NO;
    
    NSInteger allnum=[self.collectionView numberOfItemsInSection:self.fakeView.indexPath.section];
    if (self.fakeView.indexPath.row==allnum-1) {
        return NO;
    }
    if (allnum>0) {
        UICollectionViewCell *currentCell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:allnum-1 inSection:self.fakeView.indexPath.section]];
        if (currentCell) {
            if (lopoint.y>currentCell.center.y+self.itemSize.height/2.0) {
                islase=YES;
            }else if ((lopoint.x>currentCell.center.x+self.itemSize.width/2.0)&&ABS(lopoint.y-currentCell.center.y)<self.itemSize.height/2.0)
            {
                islase=YES;
            }
        }
    }
    
    if (islase) {
        [self clearlastNearIndexIsEndMoving:NO];
        NSLog(@"las 交换,%d",(int)allnum-1);
        NSIndexPath *ylasindex=self.fakeView.indexPath;
        self.fakeView.indexPath=[NSIndexPath indexPathForRow:allnum-1 inSection:self.fakeView.indexPath.section];
        __WEAKSelf
        [self.collectionView performBatchUpdates:^{
            [self.collectionView moveItemAtIndexPath:ylasindex toIndexPath:[NSIndexPath indexPathForRow:allnum-1 inSection:self.fakeView.indexPath.section]];
        } completion:^(BOOL finished) {
            if ([weakSelf.delegate respondsToSelector:@selector(collectionView:didmoveItemAtIndexPath:toIndexPath:)]) {
                [weakSelf.delegate collectionView:self.collectionView didmoveItemAtIndexPath:ylasindex toIndexPath:[NSIndexPath indexPathForRow:allnum-1 inSection:self.fakeView.indexPath.section]];
            }
        }];
    }

    return islase;
}
-(void)clearlastNearIndexIsEndMoving:(BOOL)isend
{
    if (_curintNearIndex) {
        UICollectionViewCell *lascurrentCell = [self.collectionView cellForItemAtIndexPath:_curintNearIndex];
        if (!lascurrentCell) {
            return;
        }
        [UIView animateWithDuration:0.3 animations:^{
            lascurrentCell.transform=CGAffineTransformIdentity;
            if (!isend) {
                self.fakeView.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }
        }];
        _curintNearIndex=nil;
    }
}
-(void)endMoving
{
    if (isMoving) {
        isMoving=NO;
        if (_curintNearIndex) {
            UICollectionViewCell *lascurrentCell = [self.collectionView cellForItemAtIndexPath:_curintNearIndex];
            if (lascurrentCell) {
                self.savedcurintNearIndex=_curintNearIndex;
                __WEAKSelf
                [self.fakeView pushBackViewFrame:lascurrentCell.frame isChaRu:YES completion:^{
                    if ([weakSelf.delegate respondsToSelector:@selector(collectionView:didCombineToIndexPath:toIndexPath:)]) {
                        [weakSelf.delegate collectionView:weakSelf.collectionView didCombineToIndexPath:weakSelf.fakeView.indexPath toIndexPath:weakSelf.savedcurintNearIndex];
                    }
                    [weakSelf.fakeView removeFromSuperview];
                    weakSelf.fakeView=nil;
                    [weakSelf invalidateLayout];
                }];
            }
        }
        else
        {
            [self.fakeView pushBackViewFrame:self.fakeView.cell.frame isChaRu:NO completion:^{
                [self.fakeView removeFromSuperview];
                self.fakeView=nil;
                [self invalidateLayout];
            }];
        }
        [self clearlastNearIndexIsEndMoving:YES];
    }
}


@end
