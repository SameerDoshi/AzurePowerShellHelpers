Function Write-AzureResourcesConfigFiles {
    [cmdletbinding(SupportsShouldProcess=$True)]
    Param (
        [string] [Parameter(Mandatory = $true)] $resourceGroupName,
        [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "Folder does not exist" 
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must folder"
            }
            return $true
        })]
        [System.IO.FileInfo]$outputPath
    )
        $resources=Get-AzResource -ResourceGroupName $resourceGroupName
        foreach ($resource in $resources){
            $type=$resource.ResourceType.replace('/','.')
            $filename=$resource.ResourceName + '.'+ $type +'.'+$resourceGroupName+ ".json"
            $outputName=Join-Path $outputPath $filename
            Write-Output "Writting: $outputName"
            if ($PSCmdlet.ShouldProcess($outputName)) {
                $json = ConvertTo-Json $resource    
                Out-File -FilePath $outputName -Force -InputObject $json
            }
        }
   
}

Write-AzureResourcesConfigFiles -resourceGroupName myRG_dev -outputPath .\out
Write-AzureResourcesConfigFiles -resourceGroupName myRG_qa -outputPath .\out
