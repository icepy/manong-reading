//
//  MNSearchInfoCell.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/28.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "MNSearchInfoCell.h"
#import "ManongContent.h"

@interface MNSearchInfoCell()

@property (weak, nonatomic) IBOutlet UILabel *cName;
@property (weak, nonatomic) IBOutlet UILabel *cTime;
@property (weak, nonatomic) IBOutlet UILabel *cOrigin;


@end

@implementation MNSearchInfoCell

-(void)setManongC:(ManongContent *)manongC
{
    _manongC = manongC;
    self.cName.text = manongC.wkName;
    NSURL *url = [NSURL URLWithString:manongC.wkUrl];
    NSString *trueURL = [url.query stringByRemovingPercentEncoding];
    NSArray *arr = [trueURL componentsSeparatedByString:@"="];
    NSURL *inputURL = [NSURL URLWithString:arr[1]];
    self.cOrigin.text = inputURL.host;
    NSString *readTime;
    if ([manongC.wkStatus intValue]) {
        readTime = [NSString stringWithFormat:@"阅读：%@",manongC.wkStringTime];
    }else{
        readTime = @"阅读：No";
    }
    self.cTime.text = readTime;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
