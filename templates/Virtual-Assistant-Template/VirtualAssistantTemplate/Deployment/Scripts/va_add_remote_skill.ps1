Param(
    [Parameter(Mandatory = $true)][string] $appSettingsFile,
    [Parameter(Mandatory = $true)][string] $skillConfigFile,
    [Parameter(Mandatory = $true)][string] $manifestUrl,
    [Parameter(Mandatory = $true)][string] $dispatchName,
    [string] $language = "en-us",
    [string] $luisFolder,
    [string] $dispatchFolder,
    [string] $outFolder = $(Get-Location),
    [string] $lgOutFolder = $(Join-Path $outFolder Services),
    [string] $botName,
    [string] $resourceGroup = $botName
)

# Set folder defaults
$langCode = ($language -split "-")[0]
if (-not $luisFolder) {
    $luisFolder = $(Join-Path $PSScriptRoot .. Resources Skills $langCode)
}
if (-not $dispatchFolder) {
    $dispatchFolder = $(Join-Path $PSScriptRoot .. Resources Dispatch $langCode)
}

Write-Host "Loading skill manifest ..."
$manifest = Invoke-WebRequest -Uri $manifestUrl | ConvertFrom-Json

Write-Host "Initializing skill.config ..."
if (Test-Path $skillConfigFile) {
    $skillConfig = Get-Content $skillConfigFile | ConvertFrom-Json

    if ($skillConfig) {
        if ($skillConfig.skills) {
            if ($skillConfig.skills.Id -eq $manifest.Id) {
                Write-Host "$($manifest.Id) is already registered."
            }
            else {
                Write-Host "Registering $($manifest.Id) ..."
                $skillConfig.skills += $manifest
            }
        }
        else {
            Write-Host "Registering $($manifest.Id) ..."    
            $skills = @($manifest)
            $skillConfig | Add-Member -Type NoteProperty -Force -Name "skills" -Value $skills
        }
    }
}

# if ($manifest.authenticationConnections.Count -gt 0) {
#     if (Test-Path $appSettingsFile) {
#         Write-Host "Setting up authentication connections ..."
#         if (Test-Path $appSettingsFile) {
#             if ($manifest.authenticationConnections.serviceProviderId -contains "Azure Active Directory v2") {
#                 $appSettings = Get-Content $appSettingsFile | ConvertFrom-Json
#                 $oauthConnection = $manifest.authenticationConnections | Where-Object { $_.serviceProviderId -eq "Azure Active Directory v2" }
#                 $scopesArr = $oauthConnection.scopes -split ','
#                 $scopes = $scopesArr -join ' '
#                 az bot authsetting create `
#                     --resource-group $botName `
#                     --name $resourceGroup `
#                     --setting-name $oauthConnection.Id `
#                     --client-id $appSettings.microsoftAppId `
#                     --client-secret $appSettings.microsoftAppPassword `
#                     --service Aadv2 `
#                     --parameters clientId="$($appSettings.microsoftAppId)" clientSecret="$($appSettings.microsoftAppPassword)" tenantId=common `
#                     --provider-scope-string "$($scopes)"
#             }
#         }
#         else {
#             Write-Warning "Cannot automatically provision skill OAuth Connections. You will need to set up your OAuth Connections manually."
#         }
#     }
#     else {
#         Write-Warning "Could not file $($appSettingsFile). You will need to set up your OAuth Connections manually."
#     }
# }

if (-not $skillConfig) {
    $skillConfig = @{ skills = @($manifest) }
}

$skillConfig | ConvertTo-Json -depth 100 | Out-File $skillConfigFile

Write-Host "Getting intents for dispatch ..."
$dictionary = @{ }
foreach ($action in $manifest.actions) {
    if ($action.definition.triggers.utteranceSources) {
        foreach ($source in $action.definition.triggers.utteranceSources) {
            foreach ($luisStr in $source.source) {
                $luis = $luisStr -Split '#'                
                if ($dictionary.ContainsKey($luis[0])) {
                    $intents = $dictionary[$luis[0]]
                    $intents += $luis[1]
                    $dictionary[$luis[0]] = $intents
                }
                else {
                    $dictionary.Add($luis[0], @($luis[1]))
                }
            }
        }
    }
}

Write-Host "Adding skill to Dispatch ..."
foreach ($luisApp in $dictionary.Keys) {
    $intents = $dictionary[$luisApp]
    $luFile = Get-ChildItem -Path $(Join-Path $luisFolder "$($luisApp).lu") `

    # Parse LU file
    Write-Host "Parsing $($id) LU file ..."
    ludown parse toluis `
        --in $luFile `
        --luis_culture $language `
        --out_folder $luisFolder `
        --out "$($luisApp).luis"

    $luisFile = Get-ChildItem `
        -Path $luisFolder `
        -Filter "$($luisApp).luis" `
        -ErrorAction SilentlyContinue `
        -Recurse `
        -Force

    dispatch add `
        --type file `
        --filePath $luisFile `
        --intentName $manifest.Id `
        --includedIntents $intents `
        --dataFolder $dispatchFolder `
        --dispatch $(Join-Path $dispatchFolder "$($dispatchName).dispatch")
}

Write-Host "Running dispatch refresh ..."
dispatch refresh --dispatch $(Join-Path $dispatchFolder "$($dispatchName).dispatch") --dataFolder $dispatchFolder

Write-Host "Running LuisGen ..."
luisgen $(Join-Path $dispatchFolder "$($dispatchName).json") -cs "DispatchLuis" -o $lgOutFolder