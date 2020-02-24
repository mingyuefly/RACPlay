//
//  ViewController.m
//  RACPlay
//
//  Created by Gguomingyue on 2019/12/26.
//  Copyright © 2019 Gmingyue. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <ReactiveObjC.h>
#import "RWDummySignInService.h"

@interface ViewController ()

@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) RWDummySignInService *signInService;

@end

@implementation ViewController
#pragma mark - root life time
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"RAC";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupUI];
    [self playRAC];
}

-(void)setupUI
{
    [self.view addSubview:self.usernameTextField];
    [self.view addSubview:self.passwordTextField];
    [self.view addSubview:self.nextButton];
    
    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(30);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(90);
        make.size.mas_equalTo(CGSizeMake(200, 30));
    }];
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(30);
        make.top.equalTo(self.view).offset(150);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
}

-(void)playRAC
{
    self.signInService = [[RWDummySignInService alloc] init];
    
    // ReactiveCocoa signals (represented by RACSignal)
    /*
    [self.usernameTextField.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@", x);
    }];
     */
    
    // like a pipeline
    /*
    [[self.usernameTextField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 3;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@", x);
    }];
     */
    
    // arrange the code 
    /*
    RACSignal *usernameSourceSignal = self.usernameTextField.rac_textSignal;
    RACSignal *filteredUsername = [usernameSourceSignal filter:^BOOL(id  _Nullable value) {
        NSString *text = value;
        return text.length > 3;
    }];
    [filteredUsername subscribeNext:^(id  _Nullable x) {
        NSString *text = x;
        NSLog(@"%@", text);
    }];
     */
    
    // events
    // map 在这里可以选择在管道中要传送的内容
//    [[[self.usernameTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
//        return @(value.length);
//        //return value;
//    }] filter:^BOOL(NSNumber *length) {
//    //}] filter:^BOOL(NSString *text) {
//        return length.intValue > 3;
//        //return text.length > 3;
//    }] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@", x);
//    }];
    
    // creating valid state signals
    /*
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidUsername:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidPassword:value]);
    }];
    
//    [[validPasswordSignal map:^id _Nullable(NSNumber *passwordValid) {
//        return [passwordValid boolValue]?[UIColor clearColor]:[UIColor redColor];
//    }] subscribeNext:^(UIColor *color) {
//        self.passwordTextField.backgroundColor = color;
//    }];
     
    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber *passwordValid) {
        return [passwordValid boolValue]?[UIColor clearColor]:[UIColor redColor];
    }];
    RAC(self.usernameTextField, backgroundColor) = [validUsernameSignal map:^id _Nullable(NSNumber *usernameValid) {
        return [usernameValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];
     */
    
    // combining signals
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal map:^NSNumber *(NSString * _Nullable value) {
        return @([self isValidUsername:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal map:^NSNumber *(NSString * _Nullable value) {
        return @([self isValidPassword:value]);
    }];
    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^UIColor *(NSNumber *passwordValid) {
        return [passwordValid boolValue]?[UIColor clearColor]:[UIColor redColor];
    }];
    RAC(self.usernameTextField, backgroundColor) = [validUsernameSignal map:^UIColor *(NSNumber *usernameValid) {
        return [usernameValid boolValue]?[UIColor clearColor]:[UIColor yellowColor];
    }];
    RACSignal *signUpActiveSignal = [RACSignal combineLatest:@[validUsernameSignal, validPasswordSignal] reduce:^NSNumber *(NSNumber *usernameValid, NSNumber *passwordValid){
        return @(usernameValid.boolValue && passwordValid.boolValue);
    }];
    [signUpActiveSignal subscribeNext:^(NSNumber *enabled) {
        self.nextButton.enabled = enabled.boolValue;
    }];
    
    // reactive sign-in
    /*
    [[self.nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"sign in");
    }];
     */
    [[[[self.nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(__kindof UIControl * _Nullable x) {
        self.nextButton.enabled = NO;
    }] flattenMap:^__kindof RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
        return [self signInSignal];
    }] subscribeNext:^(NSNumber *signedIn) {
        self.nextButton.enabled = YES;
        BOOL success = signedIn.boolValue;
        if (success) {
            NSLog(@"sign in successfully!");
        } else {
            NSLog(@"sign in unsuccessfully!");
        }
    }];
}

-(BOOL)isValidUsername:(NSString *)text
{
    if (text.length > 3) {
        return YES;
    }
    return NO;
}

-(BOOL)isValidPassword:(NSString *)text
{
    if (text.length > 4) {
        return YES;
    }
    return NO;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - property
-(UITextField *)usernameTextField
{
    if (!_usernameTextField) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.placeholder = @"username";
        _usernameTextField.textAlignment = NSTextAlignmentLeft;
        _usernameTextField.font = [UIFont systemFontOfSize:14];
        _usernameTextField.textColor = [UIColor blackColor];
        _usernameTextField.borderStyle = UITextBorderStyleRoundedRect;
        _usernameTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _usernameTextField;
}

-(UITextField *)passwordTextField
{
    if (!_passwordTextField) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.placeholder = @"password";
        _passwordTextField.textAlignment = NSTextAlignmentLeft;
        _passwordTextField.font = [UIFont systemFontOfSize:14];
        _passwordTextField.textColor = [UIColor blackColor];
        _passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
        _passwordTextField.clearButtonMode = UITextFieldViewModeAlways;
    }
    return _passwordTextField;
}

-(UIButton *)nextButton
{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.backgroundColor = [UIColor redColor];
        [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_nextButton setTitle:@"signIn" forState:UIControlStateNormal];
        [_nextButton setTitle:@"invalid" forState:UIControlStateDisabled];
    }
    return _nextButton;
}

-(RACSignal *)signInSignal
{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [self.signInService signInWithUsername:self.usernameTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

@end
