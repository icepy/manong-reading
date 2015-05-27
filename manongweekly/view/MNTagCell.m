//
//  MNTagCell.m
//  manongweekly
//
//  Created by xiangwenwen on 15/4/22.
//  Copyright (c) 2015年 xiangwenwen. All rights reserved.
//

#import "MNTagCell.h"
#import "ManongTag.h"

@interface MNTagCell()

@property (weak, nonatomic) IBOutlet UILabel *tagTitleName;

@end

@implementation MNTagCell

-(void)setManongTag:(ManongTag *)manongTag
{
    _manongTag = manongTag;
//    NSLog(@"%@",_manongTag.tagName);
    self.tagTitleName.text = _manongTag.tagName;
    self.tagTitleName.textAlignment = NSTextAlignmentLeft;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
