Param(
	[Parameter()]$user = '',
	[Parameter()]$password = '',
	[Parameter()]$awsClientId = '',
	[Parameter()]$awsSecret = ''
)

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $securePassword
Invoke-Command -Credential $Cred -ComputerName inputYourVMHere -ScriptBlock {

    #set env variables for AWS
    $Env:AWS_ACCESS_KEY_ID="$using:awsClientId"
    $Env:AWS_SECRET_ACCESS_KEY="$using:awsSecret"
    $Env:AWS_DEFAULT_REGION="us-east-1"

    ## Install Amazon Cli from web link and Check version
    msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi;
    aws --version;

    ## jdk download from s3 and install
    aws s3 cp "s3://s3Name/folders/jdk1.8.0_202-windows-x64.exe" "jdk1.8.0_202-windows-x64.exe";

    Start-Process -FilePath "jdk1.8.0_202-windows-x64.exe" -ArgumentList "INSTALL_SILENT=Enable AUTO_UPDATE=Disable" -Wait

    # Tomcat download from S3 and unzipping file
    aws s3 cp "s3://s3Name/folders/apache-tomcat-8.5.82-windows-x64.zip" "apache-tomcat-8.5.82-windows-x64.zip";
    Expand-Archive apache-tomcat-8.5.82-windows-x64.zip -DestinationPath "./" -Force

    # set environment variables - JAVA_HOME and CATALINA_HOME required for tomcat to function
	[System.Environment]::SetEnvironmentalVariable("JAVA_HOME", "C:\Program Files\Java\jdk1.8.0_202")
	[System.Environment]::SetEnvironmentalVariable("Path", [System.Environment]::GetEnvironmentalVariable('Path', [System.EnvironmentVariableTarget]::Machine) + ";$($env:JAVA_HOME\bin)")
	$Env:CATALINA_HOME = "C:\Users\YOUR_USER\Documents \apache-tomcat-8.5.82"

    # Get java version
    Get-Command java | Select-Object Version

    #Install Tomcat
    Start-Process -FilePath "apache-tomcat-8.5.82\bin\service.bat" -ArgumentList "install TomCatService" -Wait

}
