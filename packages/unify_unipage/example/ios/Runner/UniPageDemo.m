//
//  UniPageDemo.m
//  Runner
//
//  Created by jerry on 2024/7/16.
//

#import "UniPageDemo.h"
#import <Masonry.h>

@interface UniPageDemo ()
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *paramsTitle;
@property (nonatomic, strong) UILabel *paramsContent;
@property (nonatomic, strong) UILabel *updateContent;
@property (nonatomic, strong) UIButton *btnPush;
@property (nonatomic, strong) UIButton *btnPop;
@property (nonatomic, strong) UIButton *btnUpdateTitleBar;
@end


@implementation UniPageDemo

- (void)onCreate {
    [super onCreate];
    
    [self addSubview:self.title];
    [self addSubview:self.paramsTitle];
    [self addSubview:self.paramsContent];
    [self addSubview:self.btnPush];
    [self addSubview:self.btnPop];
    [self addSubview:self.btnUpdateTitleBar];
    [self addSubview:self.updateContent];
    
    [self setupSubviews];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    _paramsContent.text = [[self getCreationParams] description];
}

- (void)setupSubviews {
    __weak __typeof(self) weakSelf = self;
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.top.equalTo(strongSelf.mas_top).offset(5);
    }];
    
    [self.paramsTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.top.equalTo(strongSelf.title.mas_bottom).offset(5);
    }];
    
    [self.paramsContent mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.top.equalTo(strongSelf.paramsTitle.mas_bottom).offset(5);
    }];
    
    [self.btnPush mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.height.mas_equalTo(@40);
        make.top.equalTo(strongSelf.paramsContent.mas_bottom).offset(5);
    }];
    
    [self.btnPop mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.height.mas_equalTo(@40);
        make.top.equalTo(strongSelf.btnPush.mas_bottom).offset(5);
    }];
    
    [self.btnUpdateTitleBar mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.height.mas_equalTo(@40);
        make.top.equalTo(strongSelf.btnPop.mas_bottom).offset(5);
    }];
    
    [self.updateContent mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        make.left.equalTo(strongSelf.mas_left).offset(10);
        make.right.equalTo(strongSelf.mas_right).offset(-10);
        make.height.mas_equalTo(@40);
        make.top.equalTo(strongSelf.btnUpdateTitleBar.mas_bottom).offset(5);
    }];
}

#pragma mark - Override parent's method

- (id)onMethodCall:(NSString*)methodName params:(NSDictionary *)args {
    if ([methodName isEqualToString:@"flutterUpdateTextView"]) {
        self.updateContent.text = [args objectForKey:@"text"];
    }
    return @YES;
}

#pragma mark - Getter/Setter

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont boldSystemFontOfSize:14];
        _title.backgroundColor = [UIColor clearColor];
        _title.numberOfLines = 10;
        _title.text = @"I'm a iOS Native UniPage";
    }
    return _title;
}

- (UILabel *)paramsTitle {
    if (!_paramsTitle) {
        _paramsTitle = [[UILabel alloc] init];
        _paramsTitle.textAlignment = NSTextAlignmentCenter;
        _paramsTitle.font = [UIFont boldSystemFontOfSize:14];
        _paramsTitle.backgroundColor = [UIColor clearColor];
        _paramsTitle.textColor = [UIColor grayColor];
        _paramsTitle.numberOfLines = 10;
        _paramsTitle.text = @"I received following creationParams:";
    }
    return _paramsTitle;
}

- (UILabel *)paramsContent {
    if (!_paramsContent) {
        _paramsContent = [[UILabel alloc] init];
        _paramsContent.textAlignment = NSTextAlignmentCenter;
        _paramsContent.font = [UIFont systemFontOfSize:14];
        _paramsContent.backgroundColor = [UIColor clearColor];
        _paramsContent.textColor = [UIColor grayColor];
        _paramsContent.numberOfLines = 10;
    }
    return _paramsContent;
}

- (UILabel *)updateContent {
    if (!_updateContent) {
        _updateContent = [[UILabel alloc] init];
        _updateContent.textAlignment = NSTextAlignmentCenter;
        _updateContent.font = [UIFont systemFontOfSize:14];
        _updateContent.backgroundColor = [UIColor clearColor];
        _updateContent.textColor = [UIColor grayColor];
        _updateContent.numberOfLines = 10;
    }
    return _updateContent;
}


- (UIButton*)btnPush {
    if (!_btnPush) {
        _btnPush = [[UIButton alloc] init];
        _btnPush.backgroundColor = UIColor.blueColor;
        _btnPush.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnPush setTitle:@"Push to Flutter Page with params" forState:UIControlStateNormal];
        [_btnPush setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnPush setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_btnPush addTarget:self action:@selector(btnPushAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPush;
}

- (UIButton*)btnPop {
    if (!_btnPop) {
        _btnPop = [[UIButton alloc] init];
        _btnPop.backgroundColor = UIColor.blueColor;
        _btnPop.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnPop setTitle:@"Pop to previous Flutter page with result" forState:UIControlStateNormal];
        [_btnPop setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnPop setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_btnPop addTarget:self action:@selector(btnPopAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPop;
}

- (UIButton*)btnUpdateTitleBar {
    if (!_btnUpdateTitleBar) {
        _btnUpdateTitleBar = [[UIButton alloc] init];
        _btnUpdateTitleBar.backgroundColor = UIColor.blueColor;
        _btnUpdateTitleBar.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_btnUpdateTitleBar setTitle:@"Update Flutter titlebar" forState:UIControlStateNormal];
        [_btnUpdateTitleBar setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnUpdateTitleBar setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [_btnUpdateTitleBar addTarget:self action:@selector(btnUpdateTitleBarAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnUpdateTitleBar;
}


#pragma mark - button action

-(void)btnPushAction:(id)sender {
    NSDictionary *params = @{
        @"hello": @"Push - this value is passed from Native UniPage"
    };
    [self pushNamed:@"/hello" param:params];
}

-(void)btnPopAction:(id)sender {
    NSDictionary *params = @{
        @"hello": @"Pop - this value is passed from Native UniPage"
    };
    [self pop:params];
}

-(void)btnUpdateTitleBarAction:(id)sender {
    NSDictionary *params = @{
        @"title": @"Updated from native unipage!"
    };
    [self invoke:@"updateTitleBar" arguments:params];
}


@end
