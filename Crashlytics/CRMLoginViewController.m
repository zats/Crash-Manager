//
//  CRMLoginViewController.m
//  Crash Manager
//
//  Created by Sasha Zats on 12/7/13.
//  Copyright (c) 2013 Sasha Zats. All rights reserved.
//

#import "CRMLoginViewController.h"

#import "CRMAccount.h"
#import "CRMAPIClient.h"
#import "CRMConfiguration.h"
#import "UIViewController+OpenSource.h"

typedef NS_ENUM(NSInteger, CRMLoginSections) {
	kCRMLoginSectionCredentials = 0,
    kCRMLoginSectionSignIn = 1,
    kCRMLoginSectionHelp = 2
};

typedef NS_ENUM(NSInteger, CRMHelpSectionRow) {
	kCRMHelpSectionSignUp = 0,
    kCRMHelpSectionForgotPassword
};

@interface CRMLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *emailTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation CRMLoginViewController

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
	
	CRMAccount *account = [CRMAccount activeAccount];
	if (!account) {
		account = [CRMAccount MR_createEntity];
	}
	account.email = email;
	account.password = password;
	[account.managedObjectContext MR_saveToPersistentStoreAndWait];

	[self.emailTextField resignFirstResponder];
	[self.passwordTextField resignFirstResponder];

	[self _setEnabled:NO];

	@weakify(self);
	[[[CRMAPIClient sharedInstance] createSessionWithAccount:account]
	 subscribeNext:^(id x) {
		 [CRMAccount setCurrentAccount:account];
	 } error:^(NSError *error) {
		@strongify(self);
		[CRMAccount setCurrentAccount:nil];
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
		indexPathesToHighlight = @[[NSIndexPath indexPathForRow:0 inSection:kCRMLoginSectionSignIn],
                [NSIndexPath indexPathForRow:kCRMHelpSectionSignUp inSection:kCRMLoginSectionHelp],
                [NSIndexPath indexPathForRow:kCRMHelpSectionForgotPassword inSection:kCRMLoginSectionHelp]];
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
	[CRMAccount getKeychainedLastUsedUsername:&username
									 password:&password];
	self.emailTextField.text = username;
//	self.passwordTextField.text = password;
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crashington"]];
	imageView.center = CGPointMake(CGRectGetMidX(self.view.frame), -150);
	[self.tableView addSubview:imageView];

    [self crm_exposeSource];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];	
	[self.emailTextField becomeFirstResponder];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	switch ((CRMLoginSections)indexPath.section) {
		case kCRMLoginSectionSignIn:
			[self _login];
			break;

		case kCRMLoginSectionHelp:
			switch ((CRMHelpSectionRow)indexPath.row) {
				case kCRMHelpSectionSignUp:
					[[UIApplication sharedApplication] openURL:[CRMConfiguration sharedInstance].signUpURL];
					break;
					
				case kCRMHelpSectionForgotPassword:
					[[UIApplication sharedApplication] openURL:[CRMConfiguration sharedInstance].forgotPasswordURL];
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
