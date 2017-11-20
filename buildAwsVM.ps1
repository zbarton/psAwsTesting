#Builds a VM in AWS 

param(
	[string]$imageID = "ami-e3bb7399", #defaults to Windows 2016 Base server, only works on us-east-1?
	[parameter(Mandatory=$true)]
	[string]$accessKey,
	[parameter(Mandatory=$true)]
	[string]$secretKey
)

#Dependency: installation of awspowershell tools
#Located at http://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up.html
import-module awspowershell

#Configure IAM User key
set-awscredential -accesskey $accessKey -secretkey $secretKey -storeas default

#Set Default region to Virginia
Set-DefaultAWSRegion -Region us-east-1

#create a keypair, or get the existing pair
try{
	$keyPair = New-EC2KeyPair -keyname psKeyPair
}
catch{
	$keyPair = Get-EC2KeyPair -keyname psKeyPair
}

#create a security group, or get the existing group
try{
	$secGroup = New-EC2SecurityGroup -GroupName psSecGroup -GroupDescription "Security Group for Powershell builds"
	$secGroup = Get-EC2SecurityGroup -GroupID $secGroup.groupID
}
catch{
	$secGroup = Get-EC2SecurityGroup -GroupName psSecGroup
}

#build the VM
try{
	$vm = New-EC2Instance -imageID $imageID -MinCount 1 -MaxCount 1 -KeyName $keyPair.keyName -SecurityGroups $secGroup.groupName -InstanceType t1.micro
}
catch{
	Write-Error "Failed to build VM"
}

#get instance information, need to query further from here
$instance = $vm.instances[0]