Function Set-NBItem {
  [CmdletBinding(DefaultParameterSetName="Default")]
  PARAM (
    [PARAMETER(Mandatory=$True,  Position=0,HelpMessage = "NetBox FQDN or IP address",      ParameterSetName='Default')][String]$NetBox,	
    [PARAMETER(Mandatory=$True,  Position=1,HelpMessage = "Token",                          ParameterSetName='Default')][String]$Token,
    [PARAMETER(Mandatory=$True,  Position=2,HelpMessage = "Item Type (Site,Prefix,Device,Interface,VRF,Address)",ParameterSetName='Default')][String]$ItemType,	
    [PARAMETER(Mandatory=$false, Position=3,HelpMessage = "Be silent",                      ParameterSetName='Default')][bool]$Silent=$true,
    [PARAMETER(Mandatory=$True,  Position=4,HelpMessage = "Item(s)",                        ParameterSetName='Default')][Parameter(ValueFromRemainingArguments=$true)][PSObject[]]$Item = $null	
  )
  # Item(s) id should be passed as item property. It is skipped later when parsing item to JSON.
  $RetVal = $null
 
  $NBBaseURL = 'http://' + $NetBox + '/api/'
  $NBContentType = 'application/json; charset=utf-8'
  $NBHeaders = @{ Authorization = "Token $Token" }
  
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

 
  # Skipping batch cause cannot specify multiple id-s in URI
  # one-by-one Patch
  $RetVal = @()
  foreach ($CurrentItem in $Item) {
	  $NoIdCurrentItem = $CurrentItem | Select-Object * -ExcludeProperty 'id'
      $NBItemPatchBody =  $NoIdCurrentItem | ConvertTo-JSON
	  $NBItemURI = $($URI + $CurrentItem.id + '/')

      if (-not $Silent) { write-host "Set-NBItem: patching item $($NoIdCurrentItem) at URI: $($NBItemURI)" }

      try {		
	    $responseData = Invoke-RestMethod -Uri $NBItemURI -Method Patch -Headers $NBHeaders -Body $NBItemPatchBody -ContentType $NBContentType
	  }
      catch {
        if($_.ErrorDetails.Message) {
          write-host "Set-NBItem: Failed to patch $($ItemType): $($_.ErrorDetails.Message)" -foreground Red
        }
	    else {
          write-host "Set-NBItem: Failed to patch $($ItemType): $($_)" -foreground Red
        }
      }    
	  $RetVal += $responseData
	}	
  
  Return($RetVal)
}


