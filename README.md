# terraform-jupyter
Automated Jupyter notebook deployment in AWS using [Terraform](https://www.terraform.io). 

This guide assumes you have some basic knowledge of AWS, have an AWS account, have a shared credentials file, etc. This code also assumes you're using a pretty vanilla AWS account. i.e. default VPCs, subnets, etc. However, no Terraform knowledge is required to get up and running. If you want to learn more about Terraform, I **highly** recommend buying [Terraform Up and Running](https://www.amazon.com/Terraform-Running-Writing-Infrastructure-Code/dp/1492046906/ref=sr_1_1?keywords=terraform+up+and+running&qid=1571417701&sr=8-1) by Yevgeniy Brikman.

## What this Terraform script does
This Terraform will do the following automatically:

1. Creates a key-pair and puts it in your working directory.
1. Creates a AWS Security Group that is pre-configured for Jupyter Notebooks.
1. Creates a AWS Instance using the latest Amazon Linux 2 AMI.
1. Creates a EBS volume for [Anaconda](https://www.anaconda.com) Python distribution.
1. Attaches the EBS volume to the instance.
1. Mounts the EBS instance as /anaconda3
1. Downloads [Anaconda](https://www.anaconda.com)
1. Installs [Anaconda](https://www.anaconda.com)
1. Sets the environment variable for [Anaconda](https://www.anaconda.com), python, jupyter, etc
1. Configures the Jupyter Notebook config file for use with AWS.

## Install Terraform
### MacOS Users:
I use [HomeBrew](https://brew.sh) to install Terraform.

Install it by running the following command:

`/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

After installing [HomeBrew](https://brew.sh), run `brew install terraform` in the Terminal application of your choice. I **highly** recommend [iTerm2](https://iterm2.com).

### Linux Users:
Linux users should use [LinuxBrew](https://docs.brew.sh/Homebrew-on-Linux). Follow the installation instructions from that website if you are a Linux user. It's a little more cumbersome than the MacOS installation, so I'm going to leave the steps out.

After installing [LinuxBrew](https://docs.brew.sh/Homebrew-on-Linux), run 'brew install terraform' in the Terminal application of your choice.

### Windows Users
Windows users; you're on your own. I don't use Windows. Find some documentation online and figure it out yourself. :)

## Shared Credentials File
This scrips assume you're using a shared credentials file in `~/.aws/`.

You'll need to create an IAM user with programmatic access, place the `aws_access_key` and `aws_secret_access_key` in `~/.aws/credentials`. I recommend also putting in a default region inside `~/.aws/config`.

For more information see:
* [Creating an IAM User in Your AWS Account](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)
* [Create a Shared Credentials File](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/create-shared-credentials-file.html)

## File Structure
```
.
├── main.tf
├── output.tf
├── script.sh
└── var.tf
```

### main.tf
This is the *main* Terraform file. It includes all the resources created in AWS.

### output.tf
This is where you can have Terraform output certain attributes after it has completed running.

### script.sh
This is a bash shell script that executes when the EC2 instance is created. It does some lower level Linux stuff and takes care of:

1. Creating a log file for debugging.
1. Updates Amazon Linux 2 packages.
1. Mounts the EBS volume as `/anaconda3`.
1. Edits the `fstab` file inside Amazon Linux 2 to ensure the volume is not lost during a reboot.
1. Downloads and installs Anaconda.
1. Creates and configures the Jupyter Notebook config file to make Jupyter Notebook AWS friendly.

### var.tf
This is where Terraform stores variables used in `main.tf`.


## Running the Terraform Script

1. Navigate to this repo in your Terminal app.
1. Run the command `terraform plan -out=terraform.plan`.
1. You can see a preview of all the resources Terraform will create.
1. Run the command `terraform apply "terraform.plan"`.
1. You'll see Terraform creating resources. It will also place the access key-pair in your working directory for use with connecting to the ec2-instance with SSH.
1. After Terraform has completed creating resources it will output the public DNS, which you'll also use to connect with SSH.
1. Wait ~10 minutes for the start up script (`script.sh`) to complete. It takes time to download and install Anaconda, especially on a `t2.micro` instance.

## Connect to Your Instance and Run Jupyter Notebook.
1. Connect to your instance by running the following command: `ssh -i <keyname>.pem ec2-user@<public-dns>` (The public DNS was outputted by Terraform for you and your key can simply be found by typeing `key-` and then hitting tab for it to auto complete. For example, the last time I ran this command it was `ssh -i "key-df8421c2-3302-de97-3d89-aa91f169cc38.pem" ec2-user@ec2-34-216-20-94.us-west-2.compute.amazonaws.com`. You will be prompted *Are you sure you want to connect?* So, type `yes` and press enter/return.
1. You'll see that you've entered your EC2 instance.
1. Start up the Jupyter Notebook server by running the command `jupyter notebook`.
1. You'll see a URL. For example, `http://ec2-34-211-106-166.us-west-2.compute.amazonaws.com:8888/?token=6508a10c1b80248fd3537d0a98bc62a65b55e0aca402adba`. Copy and paste that link in your browser. Jupyter Notebook will load.
1. Happy coding!

## About the State File

Note that the Terraform state file is `local`. That's not always a good idea. However, I left it as `local` cause that's the easiest way to distribute working Terraform code. I suggest keeping your State file in an AWS S3 repository. For more information, I **highly** recommend buying [Terraform Up and Running](https://www.amazon.com/Terraform-Running-Writing-Infrastructure-Code/dp/1492046906/ref=sr_1_1?keywords=terraform+up+and+running&qid=1571417701&sr=8-1) by Yevgeniy Brikman.