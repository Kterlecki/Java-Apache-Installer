Param(
	[Parameter()]$user = '',
	[Parameter()]$password = '',
	[Parameter()]$awsClientId = '',
	[Parameter()]$awsSecret = ''
)

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $securePassword
Invoke-Command -Credential $Cred -ComputerName inputYourVMHere -ScriptBlock {

	$Env:JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_202"
    	$Env:Path += ";$($Env:JAVA_HOME)\bin"
	$Env:CATALINA_HOME = "C:\Users\YOUR_USER\Documents \apache-tomcat-8.5.82"

	Start-Process -FilePath "apache-tomcat-8.5.82\bin\shutdown.bat" -Wait
	Start-Process -FilePath "apache-tomcat-8.5.82\bin\service.bat" -Wait -ArgumentList "remove TomCatService" -Wait

	remove-item "apache-tomcat-8.5.82" -Recurse -Force
	remove-item "apache-tomcat-8.5.82-windows-x64.zip" -Force
	remove-item "jdk-8u202-windows-x64.exe" -Force

	$JavaAppsToDelete = "Java Auto Updater", "Java 8 update 202 (64-bit)", "Java SE Developement Kit 8 Update 202 (64-bit)"

		foreach ($jd in $JavaAppsToDelete) {
			$MyApp = Get-WmiObject -Class Win32_Product | Where-Object{$_.Name -eq "$jd"}
			$MyApp.Uninstall()
		}

}
