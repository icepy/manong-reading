//
//  MNContentCell.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/22.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "MNContentCell.h"
#import "ManongContent.h"
#import "GStaticDataSource.h"

@interface MNContentCell()

@property (weak, nonatomic) IBOutlet UILabel *contentTitle;
@property (weak, nonatomic) IBOutlet UILabel *contentTime;
@property (weak, nonatomic) IBOutlet UILabel *contentOrigin;

@end

@implementation MNContentCell

-(void)setManongContent:(ManongContent *)manongContent
{
    _manongContent = manongContent;
    NSString *readTime;
    self.contentTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentTitle.numberOfLines = 0;
    self.contentTitle.text = _manongContent.wkName;
    NSURL *url = [NSURL URLWithString:_manongContent.wkUrl];
    NSString *trueURL = [url.query stringByRemovingPercentEncoding];
    NSArray *arr = [trueURL componentsSeparatedByString:@"="];
    NSURL *inputURL = [NSURL URLWithString:arr[1]];
    self.contentOrigin.text = inputURL.host;
    if ([_manongContent.wkStatus intValue]) {
        readTime = [NSString stringWithFormat:@"阅读：%@",_manongContent.wkStringTime];
        self.contentTitle.textColor = MANREAD;
    }else{
        readTime = @"阅读：No";
        self.contentTitle.textColor = MANNOTREAD;
    }
    
    self.contentTime.text = readTime;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
