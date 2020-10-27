Manage Uptimes for 100's of VMs. Schedule Start and Shutdown Times for VMs.
===========================================================================

            


  *  Executes every 5 minutes (scheduled in Azure Scheduler) 
  *  Filters VMs that match uptime criteria and starts or stops VMs. 
  *  Parallel Executions on VMs through PowerShell workflow, so can scale to 100s of VMs.

  *  Uses Tags associated with VMs for looking to up time values. 
  *  Works across Timezones as it uses UTC based time windows. 
  *  Tags Sample. 

![Image](https://github.com/azureautomation/manage-uptimes-for-100's-of-vms.-schedule-start-and-shutdown-times-for-vms./raw/master/image1.png)



  *   


  *  The above configuration makes sure the VM is up only on Tuesday and Friday between 8:00 and 8:15 PM



** *** *




 
 




 


        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
