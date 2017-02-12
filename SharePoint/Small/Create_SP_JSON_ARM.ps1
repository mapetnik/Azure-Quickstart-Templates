# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-linux-cli-deploy-templates
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-ps-template
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-capture-image
# https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-create-vm-generalized?toc=%2fazure%2fvirtual-machines%2fwindows%2ftoc.json
# https://github.com/Azure/azure-quickstart-templates/tree/master/201-vm-specialized-vhd-existing-vnet

# "defaultValue": "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/sharepoint-three-vm"

# https://azure.microsoft.com/en-us/resources/templates/active-directory-new-domain-ha-2-dc/
# https://github.com/Azure/azure-quickstart-templates/blob/master/sqlvm-alwayson-cluster/README.md
# https://azure.microsoft.com/en-us/resources/templates/sharepoint-three-vm/

# Variables
    $Location = "West Europe" # "Location name"
    $ResourceGroupName = "DEVSPRG" # "Resource group name"
    $TemplateFile = "azuredeploy.json" # "Template file"
    $ParameterFile = "azuredeploy.parameters.json" # "Parameter file"
    $SubscriptionName = "Visual Studio Enterprise"

# Sign in to your Azure account
    Write-Host "Logging in ..."
    Login-AzureRmAccount

# Enable verbose output and stop on error
    $VerbosePreference = 'Continue'
    $ErrorActionPreference = 'Stop'

# Set the correct subscription using the subscription ID
    $SubScriptionID = Get-AzureRmSubscription -SubscriptionName $SubscriptionName
    Write-Host "Selecting subscription '$subscriptionId'"
    Select-AzureRmSubscription -SubscriptionId $SubScriptionID.SubscriptionId

# Register RPs
    Function RegisterRP {
        Param(
            [string]$ResourceProviderNamespace
        )

        Write-Host "Registering resource provider '$ResourceProviderNamespace'";
        Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace;
    }

    $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
    if($resourceProviders.length) {
        Write-Host "Registering resource providers"
        foreach($resourceProvider in $resourceProviders) {
            RegisterRP($resourceProvider);
        }
    }

# Create a resource group
    Write-Host "Creating a new ressource group ..."
    $ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if(!$ResourceGroup)
        {
            Write-Host "Resource group '$ResourceGroupName' does not exist. To create a new resource group, please enter a location.";
            if(!$Location) {
                $Location = Read-Host "ResourceGroupLocation";
            }
            Write-Host "Creating resource group '$ResourceGroupName' in location '$Location'";
            New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location
        }
        else{
            Write-Host "Using existing resource group '$ResourceGroupName'";
        }

# Navigate to scripts location path
    Write-Host "Setting the working path ..."
    $FolderPath = [Environment]::GetFolderPath("Userprofile")
    $TargetDir = "C:\Users\sstaszek\Downloads\Azure\Osram Migration\JSON\CreateSP\Small\Templates"

    Set-Location -Path $TargetDir

# Create the resources with the template and parameters
    Write-Host "Starting DEV deployment ..."
    if(Test-Path $ParameterFile) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -DeploymentDebugLogLevel All -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile -Verbose
    } else {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -DeploymentDebugLogLevel All -TemplateFile $TemplateFile -Verbose
    }

# Stopping the running deployment status
    #Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName | Remove-AzureRmResourceGroupDeployment
    #Get-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName | Stop-AzureRmResourceGroupDeployment