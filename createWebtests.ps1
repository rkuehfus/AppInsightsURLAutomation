Connect-AzureRmAccount

#Specify your resourcegroup
$rgname=""
$rg = Get-AzureRmResourceGroup -Name $rgname

#Create arrays for webtests
$pingname = @()
$pingurl = @()
$pingexpected = @()
$pingfrequency_secs = @()
$pingtimeout_secs = @()
$pingfailedLocationCount = @()
$pingdescription = @()
$pingguid = @()
$webtests = @()

$webtests = Import-Csv -Path "webtests.csv" | ConvertTo-Json
$webtests = $webtests | ConvertFrom-Json
$x = 0
foreach($test in $webtests){
  $pingname += $test.name
  $pingurl += $test.url
  $pingexpected += $test.expected
  $pingfrequency_secs += $test.frequency_secs
  $pingtimeout_secs += $test.timeout_secs
  $pingfailedLocationCount += $test.failedLocationCount
  $pingdescription += $test.description
  $newguid = New-Guid
  $pingguid += $newguid.ToString()
  $x = $x + 1
}

$pingtemplate="Webtests.template.json"
$pingpara="parameters.Webtests.json"

$job = 'job.' + ((Get-Date).ToUniversalTime()).tostring("MMddyy.HHmm")
New-AzureRmResourceGroupDeployment `
  -Name $job `
  -ResourceGroupName $rg.ResourceGroupName `
  -TemplateFile $pingtemplate `
  -TemplateParameterFile $pingpara `
  -pingname $pingname `
  -pingurl $pingurl `
  -pingexpected $pingexpected `
  -pingfrequency_secs $pingfrequency_secs `
  -pingtimeout_secs $pingtimeout_secs `
  -pingfailedLocationCount $pingfailedLocationCount `
  -pingdescription $pingdescription `
  -pingguid $pingguid


#To check your results - Get Webtests Rule for Resourcegroup
Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName -ResourceType 'microsoft.insights/webtests' -Name Google*| ft
  #To delete your Webtests Rules
Get-AzureRmResource -ResourceGroupName $rg.ResourceGroupName -ResourceType 'microsoft.insights/webtests'  -Name Google* | Remove-AzureRmResource -Force

