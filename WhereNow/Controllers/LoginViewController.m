//
//  LoginViewController.m
//  WhereNow
//
//  Created by Xiaoxue Han on 30/07/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "LoginViewController.h"
#import "UserContext.h"
#import "NSString+WhereNow.h"
#import "SVProgressHUD+WhereNow.h"
#import "ServerManager.h"

#define verticalGap 3.0
#define ktDefaultLoginTimeInterval 20.0

static CGFloat logoLowerPos = 84.0;
static CGFloat logoUpperPos = 48.0;

static CGFloat textFieldsLowerPos = 237.0;
static CGFloat textFieldsUpperPos = 190.0;

typedef enum
{
    LoginStateLoggingIn,
    LoginStateTerms,
    LoginStateForgotPassword
} LoginState;

enum  {
    INPUT_NAME = 0,
    INPUT_NAME_EXISTS,
    INPUT_PASSWORD,
    INPUT_PASSWORD_TOO_SHORT,
    INPUT_EMAIL,
    INPUT_EMAIL_INVALID,
    INPUT_CONNECTION_PROBLEM,
    INPUT_OK
};

@interface LoginViewController () {
    LoginState loginState;
    UIResponder *currentResponder;
    
    NSString *_inputUserName;
    NSString *_inputUserPassword;
    NSString *_inputUserEmail;
}

@property (strong, nonatomic) UIImageView *logo;
@property (strong, nonatomic) UIView *loginGroup;

@property (strong, nonatomic) UITextField *usernameTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UIButton *loginFacebookButton;

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UIButton *bottomRightButton;
@property (strong, nonatomic) UIButton *bottomLeftButton;
@property (strong, nonatomic) UIImageView *verticalDivider;
@property (strong, nonatomic) UITextView *termsTextView;

@property (strong, nonatomic) MASConstraint *loginGroupTopConstraint;
@property (strong, nonatomic) MASConstraint *passwordFieldTopConstraint;
@property (strong, nonatomic) MASConstraint *bottomLeftButtonRightConstraint;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [self.view addSubview:self.logo];
    
    [_logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoLowerPos));
        make.centerX.equalTo(@0);
    }];
    
    UIView *bottomGroup = [[UIView alloc] initWithFrame:CGRectZero];
    bottomGroup.backgroundColor = [UIColor clearColor];
    //bottomGroup.alpha = 0.5;
    [self.view addSubview:bottomGroup];
    
    _verticalDivider = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vertical-divider"]];
    
    _bottomRightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_bottomRightButton setTitle:@"PASSWORD" forState:UIControlStateNormal];
    [_bottomRightButton addTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    _bottomRightButton.tintColor = [UIColor darkGrayColor];
    _bottomRightButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
    
    _bottomLeftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_bottomLeftButton setTitle:@"TERMS" forState:UIControlStateNormal];
    [_bottomLeftButton addTarget:self action:@selector(openTerms:) forControlEvents:UIControlEventTouchUpInside];
    _bottomLeftButton.tintColor = _bottomRightButton.tintColor;
    _bottomLeftButton.titleLabel.font = _bottomRightButton.titleLabel.font;
    
    [bottomGroup addSubview:_bottomRightButton];
    [bottomGroup addSubview:_bottomLeftButton];
    [bottomGroup addSubview:_verticalDivider];
    
    
    [bottomGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.bottom.equalTo(@-108);
        make.top.equalTo(@430);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        
        // make.height.equalTo(@30.0);
    }];
    
    
    [_verticalDivider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@4);
        make.bottom.equalTo(@-4);
        make.centerX.equalTo(@0);
        
    }];
    
    [_bottomLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        self.bottomLeftButtonRightConstraint = make.right.equalTo(_verticalDivider.mas_left).with.offset(-8.0);
        make.centerY.equalTo(_verticalDivider);
        // make.left.equalTo(@0);
    }];
    
    [_bottomRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_verticalDivider.mas_right).with.offset(8.0);
        make.centerY.equalTo(_verticalDivider);
        // make.right.equalTo(@0);
        
    }];
    
    [self initializeTextFields];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    [self.view addGestureRecognizer:tap];
    
#ifndef DEBUG
    // login when last user logged in already
    if ([UserContext sharedUserContext].isLastLoggedin)
    {
        // set user name
        if (![[UserContext sharedUserContext].userName isEqualToString:@""])
            self.usernameTextField.text = [UserContext sharedUserContext].userName;
        
        // login
        SHOW_PROGRESS(@"Please Wait");
        [[ServerManager sharedManager] loginUserWithUserName:[UserContext sharedUserContext].userName pwd:[UserContext sharedUserContext].password success:^(NSString *sessionId, NSString *userId)
         {
             [SVProgressHUD dismiss];
             
             
             // save status
             //[UserContext sharedUserContext].userName = self.usernameTextField.text;
             //[UserContext sharedUserContext].password = self.passwordTextField.text;
             [UserContext sharedUserContext].isLastLoggedin = YES;
             [UserContext sharedUserContext].sessionId = sessionId;
             [UserContext sharedUserContext].userId = userId;
             
             [self performSegueWithIdentifier:@"goMain" sender:self];
         } failure:^(NSString *msg) {
             HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
         }];
        
    }
    else
    {
        // set user name
        if (![[UserContext sharedUserContext].userName isEqualToString:@""])
            self.usernameTextField.text = [UserContext sharedUserContext].userName;
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
 
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardShowing:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardHiding:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    // set password to empty
    self.passwordTextField.text = @""; //[self reset];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void) initializeTextFields {
    
    _emailTextField = [self loginTextFieldForIcon:@"login-email" placeholder:@"EMAIL"];
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    _usernameTextField = [self loginTextFieldForIcon:@"login-username" placeholder:@"USER NAME"];
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    _passwordTextField = [self loginTextFieldForIcon:@"login-password" placeholder:@"PASSWORD"];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    
    //usernameTextField.alpha = _passwordTextField.alpha = _emailTextField.alpha = 0.5;
    
    _submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _submitButton.backgroundColor = [UIColor colorWithRed:0.21 green:0.68 blue:0.90 alpha:1.0];
    
    _submitButton.tintColor = [UIColor whiteColor];
    _submitButton.layer.cornerRadius = 5.0;
    [_submitButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [_submitButton addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
    
    
    _loginGroup = [UIView new];
    _loginGroup.backgroundColor = [UIColor clearColor];
    
    [_loginGroup addSubview:_emailTextField];
    [_loginGroup addSubview:_usernameTextField];
    [_loginGroup addSubview:_passwordTextField];
    [_loginGroup addSubview:_submitButton];
    
    
    
    [self.view addSubview:_loginGroup];
    
    
    [_usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@42.0);
        make.width.equalTo(@260.0);
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
    }];
    
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_emailTextField);
        make.left.equalTo(_emailTextField);
        self.passwordFieldTopConstraint = make.top.equalTo(_usernameTextField.mas_bottom).with.offset(verticalGap);
    }];
    
    //Start out logging in with the email address behind password
    [_emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_usernameTextField);
        make.left.equalTo(_usernameTextField);
        make.top.equalTo(_usernameTextField.mas_bottom).with.offset(verticalGap);
    }];
    
    _emailTextField.hidden = YES;
    
    
    [_submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(_usernameTextField);
        make.left.equalTo(_usernameTextField);
        make.top.equalTo(_passwordTextField.mas_bottom).with.offset(15.0);
        make.bottom.equalTo(@0);
    }];
    
    [_loginGroup mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        _loginGroupTopConstraint = make.top.equalTo(@(textFieldsLowerPos));
    }];
    
    
}

- (UITextField *)loginTextFieldForIcon:(NSString *)filename placeholder:(NSString *)placeholder {
    
    //Gray background view
    UIView *grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 45.0, 42.0)];
    grayView.backgroundColor = [UIColor colorWithRed:0.67 green:0.70 blue:0.77 alpha:1.0];
    
    //Path & Mask so we only make rounded corners on right side
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:grayView.bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                                         cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = grayView.bounds;
    maskLayer.path = maskPath.CGPath;
    grayView.layer.mask = maskLayer;
    
    //Add icon image
    UIImageView *passwordIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:filename]];
    [grayView addSubview:passwordIcon];
    
    [passwordIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@0);
    }];
    
    //Finally make the textField
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:14.0];
    textField.textColor = [UIColor blackColor];
    textField.backgroundColor = [UIColor whiteColor];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.leftView = grayView;
    textField.placeholder = placeholder;
    textField.delegate = self;
    
    return textField;
}


# pragma mark Gesture selector
- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {
    if(currentResponder){
        [currentResponder resignFirstResponder];
    }
}

#pragma mark Navigation methods between states of the Login screen

- (void)goInto
{
    //[self goBackToLogin:nil];
    [self performSegueWithIdentifier:@"tomain" sender:self];
}

#pragma mark -check validation
- (void) updateAndCleanInput {
    _inputUserName = [self.usernameTextField.text trimmed];
    self.usernameTextField.text = _inputUserName;
    
    _inputUserEmail = [[self.emailTextField.text trimmed] lowercaseStringWithLocale:[NSLocale currentLocale]];
    self.emailTextField.text = _inputUserEmail;
    
    _inputUserPassword = self.passwordTextField.text;
}


- (int) getInputType {
    int nRet;
    
    [self updateAndCleanInput];
    
    switch (loginState) {
        case LoginStateForgotPassword:
            nRet = [self validateForgotPassword];
            break;
        default:
            //LoginStateLoggingIn
            nRet = [self validateLoggingIn];
            break;
    }
    return nRet;
}


- (int) validateForgotPassword {
    if (_inputUserEmail.length == 0) {
        return INPUT_EMAIL;
    }
    else if (![_inputUserEmail isValidEmail]) {
        return INPUT_EMAIL_INVALID;
    }
    return INPUT_OK;
}

- (int)validateLoggingIn {
    int nRet;
    if (_inputUserName.length == 0) {
        nRet = INPUT_NAME;
    } else {
        nRet = INPUT_OK;
    }
    return nRet;
}

- (void) showAlertMessage:(int) type {
    NSString* strTitle;
    switch (type) {
        case INPUT_CONNECTION_PROBLEM:
            strTitle = @"We're sorry, there is a network issue. Please try again later";
            break;
        case INPUT_NAME:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your user name" : @"Please enter a name";
            break;
        case INPUT_NAME_EXISTS:
            strTitle = @"That username is taken, please choose another";
            break;
        case INPUT_PASSWORD:
            strTitle = loginState == LoginStateLoggingIn ? @"Please enter your password" : @"Please enter a password";
            break;
        case INPUT_PASSWORD_TOO_SHORT:
            strTitle = @"That password is too short, it must be at least 6 characters";
            break;
        case INPUT_EMAIL:
            strTitle = @"Please enter your email address";
            break;
        case INPUT_EMAIL_INVALID:
            strTitle = @"That email address is not valid";
            break;
        default:
            strTitle = @"";
            break;
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:strTitle message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


#pragma mark Login

- (IBAction)onLogin:(id)sender {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
#ifndef DEBUG
    
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        SHOW_PROGRESS(@"Please Wait");
        [[ServerManager sharedManager] loginUserWithUserName:_inputUserName pwd:_inputUserPassword success:^(NSString *sessionId, NSString *userId)
        {
            [SVProgressHUD dismiss];
            
            
            // save status
            [UserContext sharedUserContext].userName = self.usernameTextField.text;
            [UserContext sharedUserContext].password = self.passwordTextField.text;
            [UserContext sharedUserContext].isLastLoggedin = YES;
            [UserContext sharedUserContext].sessionId = sessionId;
            [UserContext sharedUserContext].userId = userId;
            
            [self performSegueWithIdentifier:@"goMain" sender:self];
        } failure:^(NSString *msg) {
            HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
        }];
    }
#else
    
    // save status
    [UserContext sharedUserContext].userName = @"testuser50";
    [UserContext sharedUserContext].password = @"testuser1!";
    [UserContext sharedUserContext].isLastLoggedin = NO;
    [UserContext sharedUserContext].sessionId = @"SESID-AABB";
    [UserContext sharedUserContext].userId = @"27";
    
    [self performSegueWithIdentifier:@"goMain" sender:self];
    
#endif
}

- (void)prepareForEnteringLoginState {
    loginState = LoginStateLoggingIn;
    
    [_passwordFieldTopConstraint uninstall];
    [_passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        self.passwordFieldTopConstraint = make.top.equalTo(_usernameTextField.mas_bottom).with.offset(verticalGap);
    }];
    
    [_logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoLowerPos));
    }];
    
    [_loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(textFieldsLowerPos));
    }];
}

- (void)configureLoginState {
    loginState = LoginStateLoggingIn;
    
    [self reset];
    
    //Without these there is an unwanted fade animation
    [UIView setAnimationsEnabled:NO];
    [_bottomLeftButton setTitle:@"TERMS" forState:UIControlStateNormal];
    [_bottomRightButton setTitle:@"PASSWORD" forState:UIControlStateNormal];
    [_submitButton setTitle:@"LOGIN" forState:UIControlStateNormal];
    [UIView setAnimationsEnabled:YES];
    
    _emailTextField.hidden = YES;
    _usernameTextField.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _usernameTextField.alpha = 1.0;
    } completion:^(BOOL finished) {
        //
    }];
    
    
    [_bottomLeftButton addTarget:self action:@selector(openTerms:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomRightButton addTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)leaveLoginState {
    [_bottomLeftButton removeTarget:self action:@selector(openTerms:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomRightButton removeTarget:self action:@selector(enterForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton removeTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Terms & Conditions


- (void)openTerms:(id)sender {
    [self leaveLoginState];
    
    
    
    _termsTextView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:nil];
    _termsTextView.editable = NO;
    _termsTextView.layer.cornerRadius = 5.0;
    _termsTextView.layer.backgroundColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:0.5f] CGColor];
    
    NSString *titleText = @"Terms and Conditions of Use\n";
    NSString *bodyText = @"\n1. Terms\n\nBy accessing this app, you are agreeing to be bound the app Terms and Conditions of Use, all applicable laws and regulations...";
    
    NSDictionary *titleAttrs = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0], NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *bodyAttrs = @{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:11.0], NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSMutableAttributedString *termsText = [[NSMutableAttributedString alloc] initWithString:titleText attributes:titleAttrs];
    NSAttributedString *bodyAttString = [[NSAttributedString alloc] initWithString:bodyText attributes:bodyAttrs];
    
    [termsText appendAttributedString:bodyAttString];
    
    _termsTextView.attributedText = termsText;

    [self.view addSubview:_termsTextView];
    
    [_termsTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@256.0);
        make.height.equalTo(@218.0);
        make.centerX.equalTo(@400.0);
        make.top.equalTo(@190.0);
    }];
    
    [self.view layoutIfNeeded];
    
    [_termsTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0.0);
    }];
    
    [_logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoUpperPos));
    }];
    
    [_loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@-400.0);
    }];
    
    _bottomLeftButtonRightConstraint.offset( -8 + (_bottomLeftButton.bounds.size.width / 2.0) );
    
    [UIView animateWithDuration:0.3 animations:^{
        //_loginGroup.alpha = 0;
        _bottomRightButton.alpha = 0;
        _verticalDivider.alpha = 0;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        //Without these there is an unwanted fade animation
        [UIView setAnimationsEnabled:NO];
        [_bottomLeftButton setTitle:@"BACK" forState:UIControlStateNormal];
        [_bottomRightButton setTitle:@"PASSWORD" forState:UIControlStateNormal];
        [UIView setAnimationsEnabled:YES];
        
        [_bottomLeftButton addTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomRightButton addTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)exitTerms:(id)sender {

    
    [_bottomLeftButton removeTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomRightButton removeTarget:self action:@selector(exitTerms:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [_termsTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@400.0);
    }];
    
    [_loginGroup mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
    }];
    
    _bottomLeftButtonRightConstraint.offset(-8);
    

    [self prepareForEnteringLoginState];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _bottomRightButton.alpha = 1.0;
        _verticalDivider.alpha = 1.0;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        //Without these there is an unwanted fade animation
        [UIView setAnimationsEnabled:NO];
        
        [self configureLoginState];
        
        [UIView setAnimationsEnabled:YES];
    }];
}

#pragma mark Forgot / Rest Password

- (void)enterForgotPassword:(id)sender {
    [self leaveLoginState];
    
    loginState = LoginStateForgotPassword;
    
    _emailTextField.hidden = NO;
    
    
    [_logo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(logoUpperPos));
    }];
    _bottomLeftButtonRightConstraint.offset( -8 + (_bottomLeftButton.bounds.size.width / 2.0) );
    /*
     [_bottomLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
     make.right.equalTo(@0.0);
     }];
     */
    
    _loginGroupTopConstraint.offset(textFieldsUpperPos);
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _passwordTextField.alpha = 0;
        _usernameTextField.alpha = 0;
        _verticalDivider.alpha = 0;
        _bottomRightButton.alpha = 0;
        [self.view layoutIfNeeded];
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView setAnimationsEnabled:NO];
        
        _usernameTextField.hidden = YES;
        
        [_bottomLeftButton setTitle:@"BACK" forState:UIControlStateNormal];
        //[_bottomRightButton setTitle:@"" forState:UIControlStateNormal];
        [_submitButton setTitle:@"RESET PASSWORD" forState:UIControlStateNormal];
        
        [UIView setAnimationsEnabled:YES];
        
        [_bottomLeftButton addTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
        //[_bottomRightButton addTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
        [_submitButton addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
        
    }];
    
    
}

- (void)resetPassword {
    if (currentResponder) {
        [currentResponder resignFirstResponder];
    }
    int nInput = [self getInputType];
    
    if (nInput != INPUT_OK) {
        [self showAlertMessage:nInput];
    } else {
        
        SHOW_PROGRESS(@"Please Wait");
        //[User resetPasswordWithEmail:self.emailTextField.text success:^() {
            HIDE_PROGRESS_WITH_SUCCESS(@"Sent a mail");
        //} failure:^(NSString *msg) {
        //    HIDE_PROGRESS_WITH_FAILURE(([NSString stringWithFormat:@"Failure : %@", msg]));
        //}];
        
    }
    
}

- (void)exitForgotPassword:(id)sender {
    [_bottomLeftButton removeTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomRightButton removeTarget:self action:@selector(exitForgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    [_submitButton removeTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    
    
//    [_logo mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@(logoLowerPos));
//    }];
    
    _bottomLeftButtonRightConstraint.offset(-8);
    
//    _loginGroupTopConstraint.offset(textFieldsLowerPos);
    
    [self prepareForEnteringLoginState];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        _passwordTextField.alpha = 1.0;
        _verticalDivider.alpha = 1.0;
        _bottomRightButton.alpha = 1.0;
        
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        [self configureLoginState];
    }];
    
}

#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentResponder = textField;
    /*
     if (textField == _usernameTextField && preFilledUsername) {
     preFilledUsername = NO;
     textField.text = @"";
     }
     */
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    currentResponder = nil;
}


- (void) reset
{
    /*
     if(self.currentAccount && loginState == LoginStateLoggingIn){
     _usernameTextField.text = self.currentAccount.user.name;
     preFilledUsername = YES;
     } else {
     _usernameTextField.text = @"";
     preFilledUsername = NO;
     }
     */
    
    if (loginState == LoginStateLoggingIn && ![[UserContext sharedUserContext].userName isEqualToString:@""])
    {
        _usernameTextField.text = [UserContext sharedUserContext].userName;
    }
    
    _passwordTextField.text = @"";
    _emailTextField.text = @"";
}

#pragma mark Keyboard Methods

- (void)keyboardShowing:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    //CGRect endFrame = ((NSValue *)note.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
    _loginGroupTopConstraint.with.offset(60.0);
    
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.logo.alpha = 0.0;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardHiding:(NSNotification *)note
{
    NSNumber *duration = note.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    
    _loginGroupTopConstraint.with.offset(loginState == LoginStateLoggingIn ? textFieldsLowerPos : textFieldsUpperPos);
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.logo.alpha = 1.0;
        [self.view layoutIfNeeded];
    }];
    
}

@end
