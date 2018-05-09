# Devops

# Yummy Recipes API AWS Deployment Script

# Deployment Instructions
The following steps should help you deploy the Yummy Recipes Api to AWS platform.
* AWS Account
If you don't have an aws account already, the signup for one from here https://aws.amazon.com/ follow the step by step instruction given to create your account.
#### Create an instance
Once you have sign in your account as the IAM, then follow the overview steps below to create your first instance while details step by step instructions are also given as you follow along the wizard that creates the instance for you.
 * Select EC2 and click ```Launch instance``` button
 * Step 1: Aamzon Machine Image list, find ```Ubuntu Server 16.04 LTS (HVM), SSD Volume Type``` click the ```select``` button
 * Step 2: Instance Type, keep the default highlight ``` Free tier eligible``` in green, click ```Next Configure instance Details``` button
 * Step 3: Configure instance Details, leave the way it is and click ```Next Add Storage``` button
 * Step 4: Add Storage, leave the way it is and click ```Add Tag``` button
 * Step 5: Add Tag, click ```Add Tag``` button and enter and key:value pair for your instance e.g Name:example under the key value fields respectively
 * Step 6: Configure Security Group, click ```Add Rule``` button and two more rule. From the drop down list, select ```Custom TCP``` with port 5000 and add another with ```HTTP``` with port 80, leave the rest as it is.
 * Step 7: Review instance Launch, click ```Launch``` button
 * Step 8: In the pop dialog, select ```Create a new key pair```, enter a name e.g demo and click ```Download key pair``` and then ```Launch instance``` button. 
 * Step 9: Create a new folder on the Desktop or your preferred location and copy your downloaded key in it
 * Step 10: From the terminal or command line, cd into the new folder containing the key
 * Step 11: From your aws instance list, select the created instance and click ```Connect``` button. From the pop dialog, copy the command ```chmod 400 *.pem``` and run in your terminal.
 * Step 12: Copy the command under Example that starts with ssh the way it is and run in your terminal and type "yes" when prompted. This will open your installed aws ubuntu instance terminal.
 * Step 13: Clone this git repo using this command```git clone https://github.com/anyric/Devops.git``` from your asw ubuntu terminal. Once done cloning, cd into ```cd Devops/``` and run ```source wscript.sh``` in the terminal. This will automatically run the bash scripts installing all dependancies and deploying the API app to your new aws instances.
 * Step 14: Once script execution is complete, open your browser and copy the public DNS or public Ip address and past in the browser giving port 5000. e.g ec2-52-15-155-196.us-east-2.compute.amazonaws.com:5000 and you should see the app runing.

  



