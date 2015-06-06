//
//  TodayMNCellTableViewCell.m
//  manongweekly
//
//  Created by xiangwenwen on 15/6/6.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "TodayMNCellTableViewCell.h"

@interface TodayMNCellTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *MNTagName;
@property (weak, nonatomic) IBOutlet UILabel *MNTagCount;


@end

@implementation TodayMNCellTableViewCell

-(void)setLadderDataSource:(NSDictionary *)ladderDataSource
{
    _ladderDataSource = ladderDataSource;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.MNTagName.text = ladderDataSource[@"tagName"];
    NSNumber *count = (NSNumber *)ladderDataSource[@"tagCount"];
    self.MNTagCount.text = [NSString stringWithFormat:@"阅读数 +% zd",[count integerValue]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
