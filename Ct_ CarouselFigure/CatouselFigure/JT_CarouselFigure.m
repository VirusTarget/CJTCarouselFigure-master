//
//  CarouselFigure1.m
//  Ct_CarouselFigure
//
//  Created by CJT on 16/5/13.
//  Copyright © 2016年 CJT. All rights reserved.
//

#import "JT_CarouselFigure.h"
#import "PicCache.h"
#import "ImageScaleView.h"
@interface JT_CarouselFigure()
{
@private CGFloat Height;    //获取控件高度
@private CGFloat Width;     //获取控件宽度
}
@property (nonatomic,strong) NSArray *PicArr;       //获取图片数组
@property (nonatomic,strong) UIPageControl *PageCtr;//设置点控制器
@property (nonatomic,strong) NSTimer *Timer;        //设置计时器
@property (nonatomic,strong) NSMutableArray *ImageViewArr;

@end
@implementation JT_CarouselFigure

- (instancetype)initWithFrame:(CGRect)frame AndPicArr:(NSArray *)Pic
{
    if (self = [super initWithFrame:frame]) {
        Width = frame.size.width;
        Height = frame.size.height;
        self.PicArr = [NSArray arrayWithArray:Pic];
        self.ImageViewArr   =   [NSMutableArray array];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.scrollEnabled = YES;
        self.contentSize = CGSizeMake(Width*(Pic.count+2), Height);
        self.contentOffset = CGPointMake(Width, 0);
        self.delegate = self;
        self.OpenTimer = YES;
        [self Timer];
        [self InPutPic];
        
        UITapGestureRecognizer  *tap    =   [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowBigPic)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

/*放入图片*/
-(void)InPutPic
{
    int i;
    for (i=1;i<=self.PicArr.count;i++) {
        [self JudgeImageOrUrl:i];
    }
    [self JudgeImageOrUrl:0];
    [self JudgeImageOrUrl:i];
}

/*图片循环*/
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.Timer invalidate];
    NSInteger PicCount = self.PicArr.count;
    if (self.contentOffset.x >= (PicCount+1)*Width) {//如果是最后一张则转到第一张
        self.contentOffset = CGPointMake(Width, 0);
    }
    else if (self.contentOffset.x < Width) {//如果为第一张则转到最后一张
        self.contentOffset = CGPointMake((PicCount+1)*Width-1, 0);
    }
}

/*点的位置*/
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog([NSString stringWithFormat:@"%f/%f",self.contentOffset.x,Width]);
    self.PageCtr.currentPage = (self.contentOffset.x/Width) -1 ;
    if(self.OpenTimer){
        self.Timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(ChangeByTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_Timer forMode:NSRunLoopCommonModes];
    }
}

#pragma mark - 图片缓存
/*判断为图片还是网址*/
-(void)JudgeImageOrUrl:(NSInteger)i
{
    CGFloat ImageViewWidth = i*Width;
    if (i==0) {
        i=_PicArr.count;
    }
    if(i>_PicArr.count)
    {
        i=1;
    }
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(ImageViewWidth, 0, Width, Height)];
    if ([self.PicArr[i-1] isKindOfClass:[NSURL class]]) {
        UIImageView *VV = [self PicCache:self.PicArr[i-1]];
        VV.frame = iv.frame;
        [self addSubview:VV];
        [self.ImageViewArr addObject:VV];
    }
    else{
        UIImage *image = self.PicArr[i-1];
        [iv setImage:image];
        [self addSubview:iv];
        [self.ImageViewArr addObject:iv];
    }
    iv.userInteractionEnabled   =   NO;
}

/*从缓存中读取文件*/
-(UIImageView*)PicCache:(NSURL *)url
{
    PicCache *cache = [[PicCache alloc] initWithURL:url];
    return cache.imageV;
}
#pragma mark 计时器

/*
 ＊计时器动作
 *带动画的位移
 */
-(void)ChangeByTimer
{
    [self setContentOffset:CGPointMake(self.contentOffset.x+Width, 0) animated:YES];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if(self.OpenTimer){
        self.Timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(ChangeByTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_Timer forMode:NSRunLoopCommonModes];
    }
    self.PageCtr.currentPage = (self.contentOffset.x/Width) -1;
}
#pragma mark PageControl

/*pagecontroller点击事件*/
-(void)PageJump:(UIPageControl*)sender
{
    [self setContentOffset:CGPointMake(sender.currentPage*Width, 0) animated:YES];
}
#pragma mark    显示大图
- (void)ShowBigPic {
    int index   =   self.contentOffset.x/Width;//定位到现在是什么位置
    ImageScaleView  *imageScale =   [[ImageScaleView alloc] initWithFrame:self.superview.bounds];
    [self.superview addSubview:imageScale];
    [imageScale createWithImage:(UIImage *)[self.ImageViewArr[index-1] image]];
}

#pragma mark - 其余事件
-(void)StopTimer
{
    [self.Timer invalidate];
    self.OpenTimer = NO;
}
-(void)InVisiblePage
{
    self.PageCtr.hidden = YES;
}
-(void)SetPageControl:(UIPageControl*)Page
{
    self.PageCtr = Page;
}
#pragma mark - 懒加载
-(UIPageControl *)PageCtr
{
    if (!_PageCtr) {
        _PageCtr = [[UIPageControl alloc] initWithFrame:CGRectMake(Width*0.7, Height-25, Width*0.3, 20)];
        [_PageCtr setNumberOfPages:self.PicArr.count];
        _PageCtr.currentPage = 0;
        _PageCtr.backgroundColor = [UIColor clearColor];
        [self.superview addSubview:_PageCtr];
        [_PageCtr addTarget:self action:@selector(PageJump:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _PageCtr;
}
-(NSTimer *)Timer
{
    if (!_Timer) {
        _Timer = [NSTimer timerWithTimeInterval:3 target:self selector:@selector(ChangeByTimer) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_Timer forMode:NSRunLoopCommonModes];
        NSTimer *T = [NSTimer timerWithTimeInterval:0.05 target:self selector:@selector(PageCtr) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:T forMode:NSRunLoopCommonModes];
    }
    return _Timer;
}

@end