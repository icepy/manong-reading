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

@interface readingChartViewController()<UIGestureRecognizerDelegate,PNChartDelegate>

@property (weak, nonatomic) IBOutlet UIView *chartDrawContainsView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentView;
@property (nonatomic) PNBarChart * barChart;
@property (nonatomic) PNPieChart *pieChart;


//@property (strong, nonatomic) NSDictionary *animationIndex;
//@property (assign ,nonatomic) NSInteger animationHistryIndex;

@end

@implementation readingChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.readingChartTitle;
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BackImage"] style:UIBarButtonItemStylePlain target:self action:@selector(backForSetting)];
    self.navigationItem.leftBarButtonItem = back;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    //segment
    self.segmentView.selectedSegmentIndex = 0;
    [self.segmentView addTarget:self action:@selector(selectedNumber) forControlEvents:UIControlEventValueChanged];
    [self tagLadder];
//    self.animationHistryIndex = 0;
//    self.animationIndex = @{
//                            @"0":@2,
//                            @"1":@1,
//                            @"2":@0
//                            };
    
}

-(void)selectedNumber
{
    if (self.segmentView.selectedSegmentIndex == 0) {
        [self.pieChart removeFromSuperview];
        [self tagLadder];
    }else{
        [self.barChart removeFromSuperview];
        [self readingLadder];
    }
    
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 1.2;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    transition.type = @"push";
//    transition.subtype = kCATransitionFromLeft;
//    [self.segmentContains.layer addAnimation:transition forKey:@"ChartViewpageCurl"];
//    
//    NSString *histryKey = [NSString stringWithFormat:@"%ld",(long)self.animationHistryIndex];
//    NSNumber *histryindex = self.animationIndex[histryKey];
//    
//    NSString *currentKey = [NSString stringWithFormat:@"%ld",(long)self.segmentView.selectedSegmentIndex];
//    NSNumber *currentIndex = self.animationIndex[currentKey];
//    
//    self.animationHistryIndex = self.segmentView.selectedSegmentIndex;
//    
//    NSLog(@"current index %@",currentIndex);
//    NSLog(@"histry index %@",histryindex);
//    
//    [self.segmentContains exchangeSubviewAtIndex:[currentIndex integerValue] withSubviewAtIndex:2];
    
}


-(void)tagLadder
{
    self.barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(10, 135.0, SCREEN_WIDTH, 200.0)];
    self.barChart.backgroundColor = [UIColor clearColor];
    self.barChart.yLabelFormatter = ^(CGFloat yValue){
        CGFloat yValueParsed = yValue;
        NSString * labelText = [NSString stringWithFormat:@"%1.f",yValueParsed];
        return labelText;
    };
    self.barChart.labelMarginTop = 5.0;
    [self.barChart setXLabels:@[@"SEP 1",@"SEP 2",@"SEP 3",@"SEP 4",@"SEP 5",@"SEP 6",@"SEP 7"]];
    self.barChart.rotateForXAxisText = true ;
    
    self.barChart.yLabelSum=5;
    self.barChart.yMaxValue=100;
    
    [self.barChart setYValues:@[@1,@24,@12,@18,@30,@10,@21]];
    [self.barChart setStrokeColors:@[PNGreen,PNGreen,PNRed,PNGreen,PNGreen,PNYellow,PNGreen]];
    // Adding gradient
    self.barChart.barColorGradientStart = PNDeepGreen;
    
    [self.barChart strokeChart];
    
    self.barChart.delegate = self;
    [self.chartDrawContainsView addSubview:self.barChart];

}

-(void)readingLadder
{
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:10 color:PNLightGreen],
                       [PNPieChartDataItem dataItemWithValue:20 color:PNFreshGreen description:@"WWDC"],
                       [PNPieChartDataItem dataItemWithValue:40 color:PNDeepGreen description:@"GOOG I/O"],
                       ];
    
    self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(SCREEN_WIDTH /2.0 - 100, 135, 200.0, 200.0) items:items];
    self.pieChart.descriptionTextColor = [UIColor whiteColor];
    self.pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:11.0];
    self.pieChart.descriptionTextShadowColor = [UIColor clearColor];
    self.pieChart.showAbsoluteValues = NO;
    self.pieChart.showOnlyValues = NO;
    [self.pieChart strokeChart];
    
    
    self.pieChart.legendStyle = PNLegendItemStyleStacked;
    self.pieChart.legendFont = [UIFont boldSystemFontOfSize:12.0f];
    
    UIView *legend = [self.pieChart getLegendWithMaxWidth:200];
    [legend setFrame:CGRectMake(130, 350, legend.frame.size.width, legend.frame.size.height)];
    [self.chartDrawContainsView addSubview:legend];
    [self.chartDrawContainsView addSubview:self.pieChart];
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
