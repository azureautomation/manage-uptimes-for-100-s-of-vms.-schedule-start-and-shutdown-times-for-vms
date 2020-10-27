workflow VMUpTimeWorkflow
{

    function SetConnection()
    {
        $connectionName = "AzureRunAsConnection"
        try
        {
            # Get the connection "AzureRunAsConnection "
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

            "Logging in to Azure..."
            Add-AzureRmAccount `
                -ServicePrincipal `
                -TenantId $servicePrincipalConnection.TenantId `
                -ApplicationId $servicePrincipalConnection.ApplicationId `
                -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
        }
        catch {
            if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } else{
                Write-Error -Message $_.Exception
                throw $_.Exception
            }
        }

    }
    
    

    function TakeVMAction
    {
        param ([Object]$AzureResourceItem)

        try
        {
            $VMResource = Get-AzureRmResource -ResourceName $AzureResourceItem.Name -ResourceGroupName $AzureResourceItem.ResourceGroupName -ResourceType "Microsoft.Compute/virtualMachines"
            $CurrentTime = [System.DateTime]::UtcNow.AddMinutes(330)
            $StartTime = [datetime]::Parse($VMResource.Tags["StartTime"])
            $ShutdownTime = [datetime]::Parse($VMResource.Tags["ShutdownTime"])
            $DayOfWeek = $VMResource.Tags["DayOfWeek"]

            
            
            $VM = Get-AzureRmVM -ResourceGroupName $AzureResourceItem.ResourceGroupName -Name $AzureResourceItem.Name -Status
            if ($DayOfWeek -contains $CurrentTime.DayOfWeek)
            {
                Write-Output $DayOfWeek
                Write-Output $CurrentTime.DayOfWeek
            }
            


            if ( $CurrentTime -ge $StartTime -and $CurrentTime -le $ShutdownTime -and $DayOfWeek.Contains($CurrentTime.DayOfWeek))
            {
                    foreach ($VMStatus in $VM.Statuses)
                    { 
                        if($VMStatus.Code.CompareTo("PowerState/deallocated") -eq 0)
                        {
                            ("{0} -> VM was found in Shutdown State. Starting VM..." -f  $AzureResourceItem.Name)
                            Start-AzureRmVM -Name $AzureResourceItem.Name -ResourceGroupName $AzureResourceItem.ResourceGroupName
                            ("{0} -> VM Started." -f  $AzureResourceItem.Name)                           
                            continue
                        }
                    }

            }
            
            if ( $CurrentTime -ge $ShutdownTime -or $CurrentTime -le $StartTime -or -not $DayOfWeek.Contains($CurrentTime.DayOfWeek))
            {
                    foreach ($VMStatus in $VM.Statuses)
                    { 
                        if($VMStatus.Code.CompareTo("PowerState/running") -eq 0)
                        {
                            ("{0} -> VM was found in running State. Deallocating VM..." -f  $AzureResourceItem.Name)
                            Stop-AzureRmVM -Name $AzureResourceItem.Name -ResourceGroupName $AzureResourceItem.ResourceGroupName -Force                
                            ("{0} -> VM DeAllocated." -f  $AzureResourceItem.Name) 
                            continue
                        }
                    }


            }
            


        }
        catch {
            
            Write-OutPut $AzureResourceItem.Name "- Error Ocurred. Please verify if the Tags are configured correctly."
            Write-Error -Message $_.Exception
        }
        
       
    }

    SetConnection


    #Login-AzureRmAccount

    $vmresources = Find-AzureRmResource -TagName ManageUpTime -TagValue "True"

    #Write-Output $vmresources
    
    foreach -parallel ($vm in $vmresources)
    {
        
        TakeVMAction($vm)

    }

    


    
}


