# AzureVMAutoStopStart

## What is it?
Designed to run from a scheduled Azure runbook, this module will stop and start VMs according to the value of a given tag.  The tag will contain the times and days a VM should be stopped.  If the runbook is executing during one of these periods, the VM will be stopped.

### Tag Format
The tag must be in the format `HH:mm-hh:mm|ddd[/ddd][,...n]`.  So, a tag may look like any of the these:

| Description                                                                                            | Tag Value                                              |
|--------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| Stopped between 10.30pm - 1.30am Wednesdays                                                            | `22:30-01:30\|Wed`                                       |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays                                              | `22:30-01:30\|Wed/Thu`                                   |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays and all day Saturdays                        | `22:30-01:30\|Wed/Thu,00:00-00:00\|Sat`                  |
| Stopped between 10.30pm - 1.30am Wednesdays and Thursdays, all day Saturdays and 9am - 11:45pm Sundays | `22:30-01:30\|Wed/Thu,00:00-00:00\|Sat,09:00-23:45\|Sun` |
