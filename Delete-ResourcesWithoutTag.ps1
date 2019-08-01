Function Delete-ResourcesWithoutTag {
    [cmdletbinding(SupportsShouldProcess=$True)]
    Param (
        [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
        [string] [Parameter(Mandatory = $false)] $TagName=""    
    )
    $deleted=@()
    $resourcesInGroup=Get-AzResource -ResourceGroupName $ResourceGroupName
    foreach($resource in $resourcesInGroup){
        $skipdelete=$false
        if($resource.Tags){
            if($resource.Tags.Keys.Contains($TagName)){
                $skipdelete=$resource.Tags[$TagName]
            }
        }
        try{
            $name=$resource.name
            if($skipdelete){
                Write-Output "Skipping: $name belongs to $skipdelete"
            }else{
                Write-Output "Deleteing; $name)"
                if ($PSCmdlet.ShouldProcess($name)) {
                    Remove-AzResource -ResourceId $resource.id -Force
                    $deleted+=$name
                }
                
            }
          
        }catch{
            Write-Error "Couldn't delete- maybe resource locks present"
        }
    }
    $deleted    
}

#Sample
# login-azAccount
# Delete-ResourcesWithoutTag -ResourceGroup "myRg" -TagName "nodelete" -WhatIf 