Function New-NBItem {
  [CmdletBinding(DefaultParameterSetName="Default")]
  PARAM (
    [PARAMETER(Mandatory=$True,  Position=0,HelpMessage = "NetBox FQDN or IP address",      ParameterSetName='Default')][String]$NetBox,	
    [PARAMETER(Mandatory=$True,  Position=1,HelpMessage = "Token",                          ParameterSetName='Default')][String]$Token,
    [PARAMETER(Mandatory=$True,  Position=2,HelpMessage = "Item Type (Site,Prefix,Device,Interface,VRF,Address)",ParameterSetName='Default')][String]$ItemType,	
    [PARAMETER(Mandatory=$false, Position=3,HelpMessage = "Be silent",                      ParameterSetName='Default')][bool]$Silent=$true,
    [PARAMETER(Mandatory=$false, Position=4,HelpMessage = "Batch (send all items at once)", ParameterSetName='Default')][bool]$Batch=$true,
    [PARAMETER(Mandatory=$True,  Position=5,HelpMessage = "Item(s)",                        ParameterSetName='Default')][Parameter(ValueFromRemainingArguments=$true)][PSObject[]]$Item = $null	
  )
  $RetVal = $null
 
  $NBBaseURL = 'http://' + $NetBox + '/api/'
  $NBContentType = 'application/json; charset=utf-8'
  $NBHeaders = @{ Authorization = "Token $Token" }
  $NBURLTail = '?limit=0'
  
  <#
  switch ( $ItemType ) {
    'Prefix'             { $URI = $NBBaseURL + 'ipam/prefixes/'     }
    'Site'               { $URI = $NBBaseURL + 'dcim/sites/'        }	 
	'Device'             { $URI = $NBBaseURL + 'dcim/devices/'      }     
	'Interface'          { $URI = $NBBaseURL + 'dcim/interfaces/'   }
	'VRF'                { $URI = $NBBaseURL + 'ipam/vrfs/'         }
	'Address'            { $URI = $NBBaseURL + 'ipam/ip-addresses/' }
	'IPAddress'          { $URI = $NBBaseURL + 'ipam/ip-addresses/' }
	'ip'                 { $URI = $NBBaseURL + 'ipam/ip-addresses/' }
	'vlan'               { $URI = $NBBaseURL + 'ipam/vlans/'        }
	'cluster'            { $URI = $NBBaseURL + 'virtualization/clusters/' }
	'vm'                 { $URI = $NBBaseURL + 'virtualization/virtual-machines/' }
	'VM'                 { $URI = $NBBaseURL + 'virtualization/virtual-machines/' }
	'vInterface'         { $URI = $NBBaseURL + 'virtualization/interfaces/'   }		
	default              { $URI = $NBBaseURL + $ItemType }
  }
  #>
  
  $URI = Get-NBItemURIByItemType -NBBaseURL $NBBaseURL -ItemType $ItemType

  
  if ((([array]$Item).count -eq 1) -or ($Batch)) {
	# batch POST
	try {		
	  $NBItemAddBody = $Item | ConvertTo-JSON
	  $responseData = Invoke-RestMethod -Uri $URI -Method Post -Headers $NBHeaders -Body $NBItemAddBody -ContentType $NBContentType
	}
    catch {
      if($_.ErrorDetails.Message) {
        write-host "New-NBItem: Failed to add $($ItemType): $($_.ErrorDetails.Message)" -foreground Red
      }
	  else {
        write-host "New-NBItem: Failed to add $($ItemType): $($_)" -foreground Red
      }
    }
    
	$RetVal = $responseData
  }
  else {
	# one-by-one POST
	$RetVal = @()
	foreach ($CurrentItem in $Item) {
	  if (-not $Silent) { write-host "New-NBItem: adding item $($CurrentItem)" }
      try {		
	    $NBItemAddBody = $CurrentItem | ConvertTo-JSON
	    $responseData = Invoke-RestMethod -Uri $URI -Method Post -Headers $NBHeaders -Body $NBItemAddBody -ContentType $NBContentType
	  }
      catch {
        if($_.ErrorDetails.Message) {
          write-host "New-NBItem: Failed to add $($ItemType): $($_.ErrorDetails.Message)" -foreground Red
        }
	    else {
          write-host "New-NBItem: Failed to add $($ItemType): $($_)" -foreground Red
        }
      }    
	  $RetVal += $responseData
	}	
  }
  
  Return($RetVal)
}


