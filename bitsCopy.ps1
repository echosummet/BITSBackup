Import-Module BITSTransfer

$source = Read-Host "Put the complete path of the source folder i.e. c:\Users\Dickfor\Desktop\folderofdicks"

$destination = Read-Host "Put the full path of the destination loaction"

if (-Not(test-path $destination)) {
    $null = New-Item -Path $destination -ItemType Directory
}

$folders = Get-ChildItem -Name -Path $source -Directory -Recurse

$dispname = 'CopyJob ' + $source + ' to ' + $destination

$copyjob = Start-BitsTransfer -source $source\*.* -Destination $destination -Asynchronous -DisplayName $dispname -Priority Low

while (($copyjob.jobstate.tostring() -eq 'Transferring') -or ($copyjob.jobstate.tostring() -eq 'Connecting')) {

    Write-Host $copyjob.jobstate.tostring()
    $progress = ($copyjob.BytesTransferred/$copyjob.BytesTotal)*100
    Write-Host $progress "%"
    Sleep 3
}
Complete-BitsTransfer -BitsJob $copyjob
foreach ($i in $folders) {
    $exists = Test-Path $destination\$i
    if($exists -eq $false){
        New-Item $destination\$i -ItemType Directory
    }
    $copyjob = Start-BitsTransfer -source $source\$i\*.* -Destination $destination\$i -Asynchronous -DisplayName $dispname -Priority Low
    while (($copyjob.jobstate.tostring() -eq 'Transferring') -or ($copyjob.jobstate.tostring() -eq 'Connecting')) {
        Sleep 3
    }
    Complete-BitsTransfer -BitsJob $copyjob
}