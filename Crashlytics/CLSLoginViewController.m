//
//  CLSLoginViewController.m
//  Crashlytics
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CLSLoginViewController.h"

#import "CLSAccount.h"
#import "CLSAPIClient.h"
#import "CLSConfiguration.h"
#import "UIViewController+OpenSource.h"

typedef NS_ENUM(NSInteger, CLSLoginSections) {
	kCLSLoginSectionCredentials = 0,
	kCLSLoginSectionSignIn,
	kCLSLoginSectionHelp
};

typedef NS_ENUM(NSInteger, CLSCredentialsSection) {
	kCLSCredentialsEmail = 0,
	kCLSCredentialsPassword
};

typedef NS_ENUM(NSInteger, CLSHelpSectionRow) {
	kCLSHelpSectionSignUp = 0,
	kCLSHelpSectionForgotPassword
};

@interface CLSLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CLSLoginViewController

#pragma mark - Private

- (void)_login {
	NSString *email = self.emailTextField.text;
	NSString *password = self.passwordTextField.text;
	
	if (![[email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
		[self.emailTextField becomeFirstResponder];
		return;
	}

	if (![[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]) {
		[self.passwordTextField becomeFirstResponder];
		return;
	}
	
	CLSAccount *account = [CLSAccount activeAccount];
	if (!account) {
		account = [CLSAccount MR_createEntity];
	}
	account.email = email;
	account.password = password;
	[account.managedObjectContext MR_saveToPersistentStoreAndWait];

	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];

	[self _setEnabled:NO];

	@weakify(self);
	[[[CLSAPIClient sharedInstance] createSessionWithAccount:account]
	 subscribeNext:^(id x) {
		 [CLSAccount setCurrentAccount:account];
	 } error:^(NSError *error) {
		@strongify(self);
		[CLSAccount setCurrentAccount:nil];
		[self _setEnabled:YES];
		[[[UIAlertView alloc] initWithTitle:@"Login Error"
									message:[error localizedDescription]
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		 self.passwordTextField.text = nil;
		[self.passwordTextField becomeFirstResponder];
	} completed:^{
		@strongify(self);
		[self dismissViewControllerAnimated:YES completion:nil];
		[self _setEnabled:YES];
	}];
}


- (void)_setEnabled:(BOOL)enabled {
	self.view.userInteractionEnabled = enabled;
	
	UIColor *cellTintColor = enabled ? [UIColor colorWithRed:0.769 green:0.031 blue:0.075 alpha:1.000] : [UIColor grayColor];
	
	static NSArray *indexPathesToHighlight;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		indexPathesToHighlight = @[[NSIndexPath indexPathForRow:0 inSection:kCLSLoginSectionSignIn],
								   [NSIndexPath indexPathForRow:kCLSHelpSectionSignUp inSection:kCLSLoginSectionHelp],
								   [NSIndexPath indexPathForRow:kCLSHelpSectionForgotPassword inSection:kCLSLoginSectionHelp]];
	});

	for (NSIndexPath *indexPath in indexPathesToHighlight) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		cell.textLabel.textColor = cellTintColor;
	}
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSString *username = nil, *password = nil;
	[CLSAccount getKeychainedLastUsedUsername:&username
									 password:&password];
	self.emailTextField.text = username;
//	self.passwordTextField.text = password;
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crashington"]];
	imageView.center = CGPointMake(CGRectGetMidX(self.view.frame), -150);
	[self.tableView addSubview:imageView];
	
	[self cls_exposeSource];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	[self.emailTextField becomeFirstResponder];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch ((CLSLoginSections)indexPath.section) {
		case kCLSLoginSectionSignIn:
			[self _login];
			break;

		case kCLSLoginSectionHelp:
			switch ((CLSHelpSectionRow)indexPath.row) {
				case kCLSHelpSectionSignUp:
					[[UIApplication sharedApplication] openURL:[CLSConfiguration sharedInstance].signUpURL];
					break;
					
				case kCLSHelpSectionForgotPassword:
					[[UIApplication sharedApplication] openURL:[CLSConfiguration sharedInstance].forgotPasswordURL];
					break;
			}
			break;

		default:
			break;
	}
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	// this is the basic check for the password and email to be non-empty strings
	// TODO: extract client side validation from _login so it can be called directly
	if ([self.passwordTextField.text length] &&
		[self.emailTextField.text length]) {
		[self _login];
	}
	return YES;
}

@end
