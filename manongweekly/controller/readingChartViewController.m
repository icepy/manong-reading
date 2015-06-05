//
//  readingChartViewController.m
//  manongweekly
//
//  Created by xiangwenwen on 15/6/3.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "readingChartViewController.h"
#import <Masonry/Masonry.h>
#import <PNChart/PNChart.h>
#import "modelManager.h"
#import "ManongTag.h"
#import "ManongContent.h"

@interface readingChartViewController()<UIGestureRecognizerDelegate,PNChartDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *chartDrawContainsView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentView;
@property (weak, nonatomic) IBOutlet UILabel *notDataLabel;
@property (strong, nonatomic) PNBarChart *barChart;
@property (strong, nonatomic) PNPieChart *pieChart;
@property (strong, nonatomic) UIView *legend;
@property (strong, nonatomic) NSArray *tagPieChartDataSource;
@property (strong, nonatomic) NSArray *readBarCharDataSource;
@property (strong, nonatomic) UIView *barCharInfoContains;
@property (strong, nonatomic) UILabel *barCharInfoLabel;

@end

@implementation readingChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.readingChartTitle;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackImage"] style:UIBarButtonItemStylePlain target:self action:@selector(backForSetting)];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    self.tagPieChartDataSource = [self.manager tagLadderForStatistics];
    self.readBarCharDataSource = [self.manager readLadderForStatistics];
    
    self.chartDrawContainsView.delegate = self;
    //segment
    self.segmentView.selectedSegmentIndex = 0;
    [self.segmentView addTarget:self action:@selector(selectedNumber) forControlEvents:UIControlEventValueChanged];
    [self tagLadder];
}

-(void)selectedNumber
{
    if (self.segmentView.selectedSegmentIndex == 0) {
        [self.barChart removeFromSuperview];
        [self.barCharInfoContains removeFromSuperview];
        [self.barCharInfoLabel removeFromSuperview];
        [self tagLadder];
    }else{
        [self.pieChart removeFromSuperview];
        [self.legend removeFromSuperview];
        [self readingLadder];
    }
    
    //    self.animationHistryIndex = 0;
    //    self.animationIndex = @{
    //                            @"0":@2,
    //                            @"1":@1,
    //                            @"2":@0
    //                            };
//    CATransition *transition = [CATransition animation];
//    transition.duration = 1.2;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type = @"push";
//    transition.subtype = kCATransitionFromLeft;
//    [self.segmentContains.layer addAnimation:transition forKey:@"ChartViewpageCurl"];
//    NSString *histryKey = [NSString stringWithFormat:@"%ld",(long)self.animationHistryIndex];
//    NSNumber *histryindex = self.animationIndex[histryKey];
//    NSString *currentKey = [NSString stringWithFormat:@"%ld",(long)self.segmentView.selectedSegmentIndex];
//    NSNumber *currentIndex = self.animationIndex[currentKey];
//    self.animationHistryIndex = self.segmentView.selectedSegmentIndex;
//    NSLog(@"current index %@",currentIndex);
//    NSLog(@"histry index %@",histryindex);
//    [self.segmentContains exchangeSubviewAtIndex:[currentIndex integerValue] withSubviewAtIndex:2];
}


-(void)tagLadder
{
    
    if (!self.tagPieChartDataSource.count) {
        self.notDataLabel.hidden = NO;
        return;
    }
    self.notDataLabel.hidden = YES;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSArray *itemsColor = @[PNGreen,PNPinkGrey,PNDeepGrey];
    [self.tagPieChartDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ManongTag *tag = (ManongTag *)obj;
        CGFloat value = (CGFloat)[tag.tagCount integerValue];
        NSString *tagDescription = [NSString stringWithFormat:@"%@ %ld",tag.tagName,(long)[tag.tagCount integerValue]];
        [items addObject:[PNPieChartDataItem dataItemWithValue:value color:[itemsColor objectAtIndex:idx] description:tagDescription]];
    }];
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH /2.0 - 125, 20, 250.0, 250.0) items:items];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
    self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    self.pieChart.showAbsoluteValues = NO;
    self.pieChart.showOnlyValues = NO;
    [self.pieChart strokeChart];
    self.pieChart.legendStyle = PNLegendItemStyleStacked;
    self.pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    self.legend = [self.pieChart getLegendWithMaxWidth:200];
    [self.legend setFrame:CGRectMake(130, 300, self.legend.frame.size.width, self.legend.frame.size.height)];
    [self.chartDrawContainsView addSubview:self.legend];
    [self.chartDrawContainsView addSubview:self.pieChart];
    CGFloat scrollHeight = self.legend.frame.size.height + self.pieChart.frame.size.height + 50;
    self.chartDrawContainsView.contentSize = CGSizeMake(SCREEN_WIDTH,scrollHeight);
}

-(void)readingLadder
{
    if (!self.readBarCharDataSource.count) {
        self.notDataLabel.hidden = NO;
        return;
    }
    __weak readingChartViewController *weakSelf = self;
    self.notDataLabel.hidden = YES;
    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 25, SCREEN_WIDTH, 200.0)];
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString * labelText = [NSString stringWithFormat:@"%1.f",yValueParsed];
        return labelText;
    };
    self.barChart.labelMarginTop = 5.0;
    self.barChart.yLabelSum=5;
    self.barChart.yMaxValue=100;
    CGFloat topY =  self.barChart.frame.size.height;
    CGFloat lableY = self.barChart.frame.origin.y;
    NSMutableArray *topR = [[NSMutableArray alloc] init];
    NSMutableArray *valR = [[NSMutableArray alloc] init];
    self.barCharInfoContains = [[UIView alloc] initWithFrame:CGRectMake(0,topY+40.0,SCREEN_WIDTH,self.readBarCharDataSource.count * 20.0)];
    self.barCharInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, lableY-20.0, SCREEN_WIDTH, 20.0)];
    self.barCharInfoLabel.text = @"%百分比";
    self.barCharInfoLabel.textColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    self.barCharInfoLabel.font = [UIFont systemFontOfSize:10.0f];
    
    __block float sumCount = 0;
    [self.readBarCharDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ManongContent *mnconte = (ManongContent *)obj;
        sumCount += [mnconte.wkCount floatValue];
    }];
    
    [self.readBarCharDataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ManongContent *mnconte = (ManongContent *)obj;
        [topR addObject:[NSString stringWithFormat:@"Top %tu",idx+1]];
        float repToNumber = ([mnconte.wkCount floatValue] / sumCount)*100;
        [valR addObject:[NSNumber numberWithFloat:repToNumber]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,(idx*20.0), SCREEN_WIDTH-10, 20.0)];
        label.text = [NSString stringWithFormat:@"Top %tu -- R %zd -- %@",idx+1,[mnconte.wkCount integerValue],mnconte.wkName];
        label.textColor = [UIColor colorWithWhite:0.600 alpha:1.000];
        label.font = [UIFont systemFontOfSize:12.0f];
        [weakSelf.barCharInfoContains addSubview:label];
    }];
    [self.barChart setXLabels:topR];
    self.barChart.rotateForXAxisText = true;
    [self.barChart setYValues:valR];
    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen,PNYellow,PNGreen]];
    self.barChart.barColorGradientStart = PNMauve;
    [self.barChart strokeChart];
    self.barChart.delegate = self;
    [self.chartDrawContainsView addSubview:self.barCharInfoLabel];
    [self.chartDrawContainsView addSubview:self.barChart];
    [self.chartDrawContainsView addSubview:self.barCharInfoContains];
    CGFloat scrollHeight = self.barCharInfoLabel.frame.size.height + self.barChart.frame.size.height + self.barCharInfoContains.frame.size.height + 20.0;
    self.chartDrawContainsView.contentSize = CGSizeMake(SCREEN_WIDTH, scrollHeight);
}

-(void)userClickedOnBarAtIndex:(NSInteger)barIndex
{
    NSLog(@"%zd",barIndex);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)backForSetting{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"readingChart ---释放");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
