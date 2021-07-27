# NetBoxPowerShell
 PowerShell wrapper to NetBox API

 For Set-NBItem 'id' of that item should be provided as object's property. That property would not be passed to API.
 ```
$NBPrefixToPatch = New-Object PSObject -Property @{
  id = 10
  prefix = '10.0.0.0/8'
  vrf = 5
}
Set-NBItem -NetBox $NetBoxAddress -Token $NBToken -ItemType Prefix -Item $NBPrefixToPatch
```
will substitute "/10/" to URI and pass to API the following JSON:
```
{
    "prefix":  "10.0.0.0/8",
    "vrf":  5
}
```