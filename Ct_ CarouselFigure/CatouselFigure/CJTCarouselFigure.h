//
//  CarouselFigure1.h
//  Ct_CarouselFigure
//
//  Created by CJT on 16/5/13.
//  Copyright © 2016年 CJT. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 无限循环轮播图，可支持在线图片与本地图片混合使用
 */
@interface CJTCarouselFigure : UIScrollView <UIScrollViewDelegate>

@property (nonatomic,assign) Boolean OpenTimer;

/*图片数组*/
@property (nonatomic,strong) NSArray *PicArr;

#pragma mark- method
/*通过图片或者URL数组创建控件*/
- (instancetype)initWithFrame:(CGRect)frame AndPicArr:(NSArray *)Pic;
/*关闭计时器*/
- (void)StopTimer;
/*关闭pagecontroller显示*/
-(void)InVisiblePage;

@end
