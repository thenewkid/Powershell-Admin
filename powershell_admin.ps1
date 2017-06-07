<# Exploring the depths of powershell #>

<# 1. List multiple ways to extract a service by name #>
<# 2. Benchmark them and show the fastest way to perform a specific function #>
function serviceByNameV1([String]$serviceName) {
    get-service | where {
        $_.name -eq $serviceName
    }
}

function serviceByNameV2([String]$serviceName) {
    (get-service).where{$_.name -eq $serviceName}
}

function serviceByNameV3([String]$serviceName) {
    get-service | foreach {
        if ($_.name -eq $serviceName) {
            write $_
        }
    }
}

function serviceByNameV4([String]$serviceName) {
    foreach ($service in (get-service)) {
        if ($service -eq $serviceName) {
            $_
        }
    }
}

function serviceByNameV5([String]$serviceName) {
    get-service -name $serviceName 
}

function testGetService {
    write "[+] Measuring serviceByNameV1"
    measure-command { serviceByNameV1 "MySQL57" }
    
    write "[+] Measuring serviceByNameV2"
    measure-command { serviceByNameV2 "MySQL57" }
    
    write "[+] Measuring serviceByNameV3"
    measure-command { serviceByNameV3 "MySQL57" }

    write "[+] Measuring serviceByNameV4"
    measure-command { serviceByNameV4 "MySQL57" }

    write "[+] Measuring serviceByNameV5"
    measure-command { serviceByNameV5 "MySQL57" }
}

<# Manipulate user accounts #>
function addUser([String]$username, [String]$password) {
    measure-command {
        net user $username $password /add 
    }
}

function deleteUser([String]$username) {
    measure-command {
        net user $username /delete
    }
}

function changePassword([String]$username, [String]$password) {
    measure-command {
        net user $username $password
    }
}

function testUserManipulation {
    write "[+] You must be running this program as administrator"
    write "[+] Adding user johnnysmoke with password secretpassword1"
    addUser "johnnysmoke" "secretpassword1"
    net user 

    write "[+] Changing password of johnnysmoke from secretpassword1 to garbage"
    changePassword "johnnysmoke" "garbage"
    net user 

    write "[+] Deleting user johnnysmoke "
    deleteUser "johnnysmoke"
    net user 

}

<# Remote Management #>
function addRemoteHostsFromFile([String]$filepath) {
    $lines = get-content $filepath
    $linesCSV = $lines -join ","
    winrm set winrm/config/client "@{TrustedHosts="'"'$linescsv'"'"}"
}

function showTrustedHosts {
    ls wsman:\localhost\client\TrustedHosts
}

function deleteTrustedHosts {
    clear-item wsman:/localhost/client/TrustedHosts
}

function replaceTrustedHost([String]$oldHost, [String]$newHost) {
    $trustedHostsValue = (get-item wsman:/localhost/client/trustedhosts).value 
    $csvToArray = $trustedHostsValue -split ","
    if ($csvToArray -contains $oldHost) {
        $trustedHostsValue = $trustedHostsValue.replace($oldHost, $newHost)
        winrm set winrm/config/client "@{TrustedHosts="'"'$trustedHostsValue'"'"}"
        showTrustedHosts 
    } else {
        write "[+] Host $oldHost is not a TrustedHost"
    }
}

function testRemoteManagement {
    $filename = "$env:userprofile/OpenSource/PowershellHelper/remotehosts.txt"
    
    write "[+] Showing current TrustedHosts"
    showTrustedHosts

    write "[+] Adding Remote hosts from file"
    addRemoteHostsFromFile "$env:userprofile/OpenSource/PowershellHelper/remotehosts.txt"

    write "[+] Showing current TrustedHosts"
    showTrustedHosts

    write "[+] Replacing TrustedHost garbage with newgarbage"
    replaceTrustedHost "garbage" "newgarbage"
    showTrustedHosts

    write "[+] Replace TrustedHost host_that_doesnt_exist with host test_host"
    replaceTrustedHost "host_that_doesnt_exist" "test_host"

    write "[+] Deleting TrustedHosts, current TrustedHosts are now"
    deleteTrustedHosts
    showTrustedHosts

}

<# File Management #>
function createFile([String]$filename) {
    new-item -type file $filename
}

function removeFile([String]$filename) {
    rm $filename -force
}

function testFileManagement {

}

<# Csharp environment handler #>
function testCsharpEnvironment {

}

<# Program Execution [Start] #>
function main {
    testGetService
    testUserManipulation
    testRemoteManagement
    testFileManagement
}

