<#
.Synopsis
   Uses HandBrake CLI and converts videos in the $SourceFolder to a $DestinationFolder.
.DESCRIPTION
   Uses HandBrake CLI and converts videos in the $SourceFolder to the $DestinationFolder.  
   You can change the default handbreak presets to your liking.  I use this to upload personal videos to my iTunes Library.
   I also use a scheduled task to run this so anything I copy to my $SourceFolder will get uploaded to iTunes.
.EXAMPLE
   Convert-HandbrakeVideo -SourceFolder C:\videos -DestinationFolder C:\ConvertedVideos
.EXAMPLE
   Convert-HandbrakeVideo -SourceFolder C:\videos -DestinationFolder C:\ConvertedVideos -Preset "Super HQ 1080p30 Surround" -Log -LogFile C:\temp\Log.txt
#>
function Convert-HandbrakeVideo
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
        $SourceFolder,
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=1)]
        $DestinationFolder,
        [switch]$Log,
        $Logfile = 'C:\temp\Convert-HandbrakeVideo.txt',
        $Preset = "Super HQ 1080p30 Surround"
    )

    Begin{
        Set-Location $SourceFolder
        If($log){
            "-----------------------------------------" >> $logfile
            get-date >> $logfile
            "-----------------------------------------" >> $logfile
        }
        
        Write-Verbose "Checking for Handbrake CLI"
        if (!(Test-Path "C:\Program Files\HandBrake\HandBrakeCLI.exe")){
            throw "HandbrakeCLI not found here C:\Program Files\HandBrake\HandBrakeCLI.exe"
            return
        }
    }
    Process{
        Write-Verbose "Setting SourceFolder and looking for files to convert"
        $SourceFolder = @()
        $Sourcetemp = $SourceFolder + "\*"
        $SourceFolder = Get-ChildItem $Sourcetemp -include *.mov,*.avi,*.mp4,*.m4v -recurse
        $num = $SourceFolder | measure
        $filecount = $num.count
        $i = 0
        
        Write-Verbose "Loop through Files"
        ForEach ($file in $SourceFolder){
            $i++
            Write-Progress -Activity "Converting Videos to iTunes" -status "Converting $file..." -percentComplete (($i / $fileCount)*100)
            $oldfile = $file.DirectoryName + "\" + $file.BaseName + $file.Extension;
            $dir = $file.DirectoryName    
    
            if($file.FullName -like "*.mov" -and $file.BaseName -notlike "clip*"){
                $updatedname = ($file.LastWriteTime).ToString("yyyy-MM-dd hh-mm-ss")
                $temp = $updatedname -match '\d{4}'
                $year = $Matches.Values
                $newdest = $destlocation
                $newfile = $newdest + $updatedname + ".mov";
                
                if(!(Test-Path $newfile)){
                    If($log){
                        Write-Output "Copying...$newfile" >> $logfile
                        copy-item $oldfile -Destination $newfile
                    }
                }
                else{
                    If($log){
                        Write-Output "Skipping...$newfile" >> $logfile
                    }
                }
            }

            elseif($file.BaseName -like "clip-*"){
                [string]$tempstring = $file.BaseName
                $updatedname = $tempstring.replace("clip-","").replace(";","-")
                $temp = $updatedname -match '\d{4}'
                $year = $Matches.Values
                $newdest = $destlocation
                $newfile = $newdest + $updatedname + ".mp4";
                
                If($log){
                    convert-video -newfile $newfile -preset $preset -oldfile $oldfile -log -logfile $logfile
                }
                else{
                    convert-video -newfile $newfile -preset $preset -oldfile $oldfile -logfile $logfile
                }
            }

            else{
                $updatedname = ($file.LastWriteTime).ToString("yyyy-MM-dd hh-mm-ss")
                $temp = $updatedname -match '\d{4}'
                $year = $Matches.Values
                $newdest = $destlocation
                $newfile = $newdest + $updatedname + ".mp4";
                
                If($log){
                    convert-video -newfile $newfile -preset $preset -oldfile $oldfile -log -logfile $logfile
                }
                else{
                    convert-video -newfile $newfile -preset $preset -oldfile $oldfile -logfile $logfile
                }
            }
        }
    }
    End{
        
    }
}

function convert-video {
    param($newfile,$preset,$oldfile,[switch]$log,$logfile)
    if(!(Test-Path $newfile)){
        If($log){
            Write-Output "Converting...$newfile" >> $logfile
        }
        Start-Process "C:\Program Files\HandBrake\HandBrakeCLI.exe" -ArgumentList "-i `"$oldfile`" -o `"$newfile`" -f mp4 -Z `"$preset`"" -Wait #-NoNewWindow
    }
    else{
        If($log){
            Write-Output "Skipping...$newfile" >> $logfile
        }
    }
}