# AzureVMAutoStopStart

## What is it?
A powershell workflow runbook, "Stop-Start-Azure-VMs", and a powershell module, "AzureVMAutoStopStart".  

## How do I use it?
The runbook should run under a schedule within an Azure Automation Account, and uses the module to determine, based the subscription and tag names supplied, which VMs should be stopped or started.  The tag should contain the times and days a VM should be _stopped_.  If the runbook is executing during one of these periods, the VM will be stopped (if started).  Otherwise the VM will be started (if stopped).

### Tag Format
The tag must be in the format `HH:mm-hh:mm|ddd[/ddd][,...n]`.  So, a tag may look like any of the these:

| Description                                                                                            | Tag Value                                              |
|--------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| Stopped between 10.30pm - 1.30am Wednesdays                                                            | `22:30-01:30\|Wed`                                       |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays                                              | `22:30-01:30\|Wed/Thu`                                   |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays and all day Saturdays                        | `22:30-01:30\|Wed/Thu,00:00-00:00\|Sat`                  |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays, all day Saturdays and 9am - 11:45pm Sundays | `22:30-01:30\|Wed/Thu,00:00-00:00\|Sat,09:00-23:45\|Sun` |
