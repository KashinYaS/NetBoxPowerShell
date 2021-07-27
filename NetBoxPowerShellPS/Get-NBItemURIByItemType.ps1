function Get-NBItemURIByItemType {
  PARAM (
    [PARAMETER(Mandatory=$True,  Position=0,HelpMessage = "NetBox FQDN or IP address",ParameterSetName='Default')][String]$NBBaseURL,	
    [PARAMETER(Mandatory=$True,  Position=1,HelpMessage = "NetBox Item Type",         ParameterSetName='Default')][String]$ItemType
  )	
	
  $NBBaseURL = $NBBaseURL.Trim()
  if (-not ($NBBaseURL[$NBBaseURL.Length-1] -eq '/')) {
	  $NBBaseURL = $NBBaseURL + '/'
  }
  $ItemType = $ItemType.Trim().ToLower()
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
	'vInterface'         { $URI = $NBBaseURL + 'virtualization/interfaces/'   }	
	default              { $URI = $NBBaseURL + $ItemType + '/'}
  } 
  
  return $URI
}


