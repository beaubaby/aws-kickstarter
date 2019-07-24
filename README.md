# AWS Kickstarter

This is a comprehensive toolkit for provisioning AWS accounts for a couple of common scenarios [in a secure way](https://www.thoughtworks.com/insights/blog/using-aws-security-first-class-citizen), with best practices applied by default. The kickstarter is using [a set of modules](https://github.com/moritzheiber/terraform-aws-core-modules) which are consistently tested and developed in an ongoing fashion.

## Prerequisites

The following tools are required:

- [Terraform](https://terraform.io) (**>= 0.12.4**)
- [awscli](https://aws.amazon.com/cli/) (>= 1.15.49)
- Any device (e.g. a [NitroKey](https://www.nitrokey.com/) or [YubiKey](https://www.yubico.com/product/yubikey-5-nfc)) and/or app (for either [Android](https://f-droid.org/repository/browse/?fdfilter=totp&fdid=net.bierbaumer.otp_authenticator) or [iOS](https://cooperrs.de/othauth.html)) that supports [2FA/TOTP](https://en.wikipedia.org/wiki/Multi-factor_authentication).

_Note: Although AWS [now supports](https://aws.amazon.com/blogs/security/use-yubikey-security-key-sign-into-aws-management-console/) the modern [FIDO2 procotol](https://fidoalliance.org/fido2/) for adding a second factor to your account [it lacks support for the command line](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_u2f_supported_configurations.html), which renders it an unsuable option for most of what you'd either do with this kickstarter or AWS APIs in general._

## Behind the kickstarter

### IAM setup
The kickstarter is using the paradigm of a MFA-enabled account assumption model, whereas users aren't granted permissions directly for their users, but rather will have to [assume certain roles] in order to carry out activities (e.g. starting workloads, creating resources, saving files etc.). They can do this either in the web console, or, preferably, using the API (e.g. through this kickstarter using Terraform).

![AWS IAM setup](https://raw.githubusercontent.com/moritzheiber/terraform-aws-core-modules/master/files/aws_iam_setup.png)

### VPC Network design

The VPC setup you're getting with this kickstarter is a classic DMZ-model, whereas resources are never directly exposed to the public Internet but are rather living in their separate zone, segregated from other publicly accessible resources. Ideally, those are only load balancers or edge endpoints, but never actual instances or functions with compute workloads.

![AWS VPC setup](https://raw.githubusercontent.com/moritzheiber/terraform-aws-core-modules/master/files/aws_vpc.png)


### AWS Config for auditing (and enforcement) purposes

## Available scenarios

### One IAM account

### Two IAM accounts (or 1+n IAM accounts)

### AWS Config

### VPC

### AWS Config + IAM in one account + VPC

### AWS COnfig + IAM in two accounts (or 1+n) + VPC

## Credentials setup

## Upcoming scenarios

- cloudtrail
- state-bucket

### Initial run

The initial run will need to be performed using your account `root` credentials. You can create them using the AWS Web Console by logging in using your `root` credentials (the initial email and password combination you used to sign-up for AWS) and navigating to the dropdown on the top right corner with your name, or the name you gave the account, on it:

1. Select "My Security Credentials"
2. Discard the warning screen by clicking on "Continue to Security Credentials", we will only be doing this once and removing the access credentials afterwards
3. Select "Access keys (access key ID and secret access key)"
4. Select "Create new access key"
5. Click on "Show Access Key"
6. Note down both of the values and close the overlay.

Now, set up a profile for the root credentials with the AWS CLI:

```sh
$ aws configure --profile root-account
```

For the `AWS Access Key ID` and `AWS Secret Access Key` use the values you've just written down. The default region should be `eu-west-1`. The output format doesn't matter.

You can now run the `run` script to provision all the resouces in this kickstarter:

```sh
$ AWS_PROFILE="root-account" ./run terraform apply
```

It should show you up to 50 resources. Enter `yes` to let Terraform do its work.

**Beware: From this point on forward AWS will charge you for their services**, albeit a very small amount.

#### Setting the initial passwords for the two users

There are two users provisioned initially, `admin` and `user`. The `admin` user has access to all services within your account, while the `user` user has access to all features **except** IAM (because it handles identity and access management; you don't want everyone to mess with that). Both of them need passwords set to work correctly. You can do this in the "IAM" service.

1. Select the "Services" dropdown from the upper left corner while still logged into the `root` account.
2. Search for "IAM" in the build-in search
3. Click on first, and only, result
4. You should now see a console in front of you where it says "Users" on the left hand side. Click on "Users".
5. Click on "admin" and go to the tab "Security credentials"
6. Select "Manage password" and assign a good and secure password for the user "admin". _Note: It will only allow for passwords with a mimimum of 32 characters, at least 1 digit, 1 upper- as well as lowercase character, and at least 1 symbol_
7. Repeat these steps for the second user "user"

You are now all set and should be able to log into the same web console with your regular users.

**Before you go, please deactivate the Access Key you created earlier under "My Security Credentials"**. In the future you can use your "admin" user to manage any and all resources inside your account.

_Note: You can provision user login profiles using Terraform and GPG keys without having to set passwords manually. For more information please refer to the [Terraform documentation for aws\_iam\_login\_profile](https://www.terraform.io/docs/providers/aws/r/iam_user_login_profile.html)._

### Initial user setup and user console access

From now on you only want to use either the "admin" or the "user" IAM account to manage your resources.

For this to work you will have to log on to AWS using your sign-in URL: [https://account-\<your-account-id\>.signin.aws.amazon.com/console](https://account-\<your-account-id\>.signin.aws.amazon.com/console) using the username and password you've created after the initial run for either of the accounts. Go back to the IAM console, like you did in the step before, and find the user you want to modify under "Users > <username>".

_Note: Don't mind the error messages. Your bare account doesn't have enough permissions to access all of the IAM API._

Select the tab "Security credentials" and click on the pencil icon next to "Assigned MFA device" at the top (it should read "No" next to it). You **have to choose virtual MFA** here, even if you own a physical key (YubiKey/Nitrokey). Hardware MFAs for Amazon are devices specifically made for this purpose.

Follow the steps outlined in the wizard and complete your MFA association. Once it's done there should be a device ARN akin to `arn:aws:iam::<your-account-id>:mfa/username` instead of "No" next to "Assigned MFA device". **Log out of the account**. It's necessary because your current session doesn't carry a MFA session token, but rather just a "regular" one, which won't let you create access keys.

Once you're logged back in navigate back to the "Security credentials" tab in the IAM service. Now click on "Create access key".

**Note: This is extremely important. DO NOT SHARE THESE TWO VALUES WITH ANYONE, EVER.** Both of them are the keys to your account. You will need both of them for the next setup step. Write them down somewhere safe (password safe/store).

_Note: `awstools` will rotate these keys for you on a regular basis._

### Setting up the AWS CLI

Set up a profile for main account with the AWS CLI:

```sh
$ aws configure --profile main-account
```

Use the `AWS Access Key ID` and `AWS Secret Access Key` of the credential set you just created. The default region should be `eu-west-1`. The output format doesn't matter.

### Setting up `awstools`

We'll be using `awstools` to assume a role in AWS with 2FA in order to manipulate resources. Your regular account will not have access to any of the AWS APIs.

Instead, the credentials of the assumed role will be used. They are only valid for 4 hours, after which you will have to run through the assuming process again to receive new temporary credentials.

Copy the template from `awstools/example-config.toml` to `${HOME}/.config/awstools/config.toml`, enter the right account ID into the configuration file (you should be able to fetch it from Web console or Terraform state) and try the following command:

```sh
$ awstools assume main-account DeveloperAccess
```

and enter your MFA pin at the prompt.

This tells `awstools` to assume the role `DeveloperAccess` in the account `main-account` and obtain temporary credentials for the profile "`main-account DeveloperAccess`" which will now enable you to work with resources on AWS.

_Note: Temporary credentials for the role `DeveloperAccess` are valid for **4 hours**, for `AdminAccess` just **1 hour**. You will have to re-assume the role should these credentials expire._

You're all set now!

## Using the web console

If you log into the web console using your regular username and password together with your MFA device you will not have access to any of the resources within the account. Just like on the command line you will have to assume either the role `DeveloperAccess` (most cases) or `AdminAccess` (very rare cases).

Click on "username@account-<your-account-id>", next to the bell icon on the top right corner, and select "Switch Role" from the dropdown. Enter "account-<your-account-id>" as the account, and either `DeveloperAccess` or `AdminAccess`as the role to be assumed. You're free to choose anything of your liking for "Display Name" or color. Click on "Switch Role" to finish the process.

You will now have assumed the role you selected before, indicated by the changed appearance of the tile next to the bell icon at the top right corner.

Should you want to drop your allivated privileges at any moment in time just select "Back to username" from the same dropdown.

## Provisioning IAM and the VPC

Once you're done with the setup and want to run additional steps you can assume the role `AdminAccess`:

```sh
$ awstools assume main-account AdminAccess
```

and then run:

```sh
$ AWS_PROFILE="main-account AdminAccess" ./run terraform apply
```

so see what changes Terraform would be proposing for your account. If you're satisfied with the proposal apply it by entering: `yes`

## Destroying it all again

You will need `root` account credentials again, because halfway through you are going to remove all the access credentials and user information required to access the APIs. Once you have a valid access key and secret access key for your root account again (to obtain them run through the same steps again above) just run:

```sh
$ AWS_PROFILE="root-account" ./run terraform destroy
```

Terraform will ask you for confirmation again at the end. Answer with `yes`.
