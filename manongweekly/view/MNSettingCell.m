//
//  MNSettingCell.m
//  manongweekly
//
//  Created by xiangwenwen on 15/5/8.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "MNSettingCell.h"

@interface MNSettingCell()
@property (weak, nonatomic) IBOutlet UILabel *settingInfoShow;

@end

@implementation MNSettingCell


-(void)setMNSettingInfo:(NSDictionary *)MNSettingInfo
{
    _MNSettingInfo = MNSettingInfo;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.settingInfoShow.text = MNSettingInfo[@"setName"];
    self.imageView.image = [UIImage imageNamed:MNSettingInfo[@"setIcon"]];
    
    if (self.section > 0) {
        self.accessoryType = UITableViewCellAccessoryNone;
//        self.settingInfoShow.textAlignment = NSTextAlignmentCenter;
//        [self.settingInfoShow setTextColor:[UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000]];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
