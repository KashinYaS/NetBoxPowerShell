Function Get-NBItem {
  [CmdletBinding(DefaultParameterSetName="Default")]
  PARAM (
    [PARAMETER(Mandatory=$True,  Position=0,HelpMessage = "NetBox FQDN or IP address",ParameterSetName='Default')][PARAMETER(ParameterSetName='ItemProp')][PARAMETER(ParameterSetName='ItemID')][String]$NetBox,	
    [PARAMETER(Mandatory=$True,  Position=1,HelpMessage = "Token",                    ParameterSetName='Default')][PARAMETER(ParameterSetName='ItemProp')][PARAMETER(ParameterSetName='ItemID')][String]$Token,
    [PARAMETER(Mandatory=$True,  Position=2,HelpMessage = "Item Type (Site,Prefix,Device,Interface,VRF,Address)",ParameterSetName='Default')][PARAMETER(ParameterSetName='ItemProp')][PARAMETER(ParameterSetName='ItemID')][String]$ItemType,	
    [PARAMETER(Mandatory=$True,  Position=3,HelpMessage = "Item Property Name",       ParameterSetName='ItemProp')][String]$ItemPropName = $null,
    [PARAMETER(Mandatory=$True,  Position=3,HelpMessage = "Item Property Value",      ParameterSetName='ItemProp')][String]$ItemPropValue = $null,	
    [PARAMETER(Mandatory=$True,  Position=3,HelpMessage = "Item ID",                  ParameterSetName='ItemID')][int]$ItemID = $null,
    [PARAMETER(Mandatory=$false, Position=5,HelpMessage = "Be silent",                ParameterSetName='Default')][PARAMETER(ParameterSetName='ItemProp')][PARAMETER(ParameterSetName='ItemID')][bool]$Silent=$true	
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

  if ($ItemID) {
	  $URI = $URI + $ItemID + '/'
  }

  $URI = $URI + $NBURLTail
  
  if ($ItemPropName) {
	  $URI = $URI + '&' + $ItemPropName + '=' + [System.Web.HttpUtility]::UrlEncode($ItemPropValue)
  }
  
  
  # not using Invoke-RestMethod due to encoding bug
  $NBItems = @()

  do {
   if (($RawData.count) -and (-not $Silent)) {
     $PercentComplete = [math]::Floor($NBItems.Count / $RawData.count * 100)
     Write-Progress -Activity "Processing Netbox Items ($($ItemType))" -CurrentOperation "Searching" -PercentComplete $PercentComplete
   }
    $request = [System.Net.WebRequest]::Create("$($URI)")
    $request.ContentType = $NBContentType
    $request.Accept = "application/json"
    $request.Headers.Add('Authorization',"Token $NBToken")
    try {
      $response = $request.GetResponse()
      $reader = new-object System.IO.StreamReader($response.GetResponseStream())
      $RawData = ConvertFrom-Json $reader.ReadToEnd()
      if ($RawData) {
	    if ($RawData.Count) {
		  $NBItems = $NBItems + $RawData.results
		}
		else
		{
		  $NBItems = $NBItems + $RawData
		}
	  }
	}
    catch {
      if($_.ErrorDetails.Message) {
        write-host "Get-NBItem: $($_.ErrorDetails.Message)" -foreground Red
		$NBItems = @()
      }
	  else {
        write-host "Get-NBItem: $($_)" -foreground Red
		$NBItems = @()
      }
	}
    $URI = $RawData.next
  } while ($RawData.next)

  $RetVal = $NBItems
  
  Return($RetVal)
}


