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

function addNewRemoteHost([String]$hostName) {
    $hostName >> ~/global_hosts.txt
}

function update {
    addRemoteHostsFromFile ~/global_hosts.txt
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

function createDirectory([String]$filename) {
    mkdir $filename 
}

function removeFile([String]$filename) {
    rm $filename -force
}

function removeDirectory([String]$filepath) {
    rm $filepath -recurse -force
}

function copyFile([String]$sourcePath, [String]$destinationPath) {
    cp $sourcePath $destinationPath
}

function renameOrMoveFile([String]$sourcePath, [String]$destinationPath) {
    mv $sourcePath $destinationPath
}

function testFileManagement {
    write "[+] Creating file test.txt in Local Directory: replaced".replace("replaced", (pwd))
    createFile "test.txt"
    if (test-path "test.txt") {
        write "[+] test.txt successfully created replaced".replace("replaced", (ls test.txt))
        write "[+] Deleting test.txt"
        removeFile "test.txt"
        if (-not (test-path "test.txt")) {
            write "[+] test.txt successfully deleted"
        } else {
            throw "FileNotDeletedException"
        }
    } else {
        throw "FileNotCreatedException"
    }

    write "[+] Creating test directory in LocalDirectory"
    createDirectory "testDir"
    if (test-path "testDir") {
        write "[+] testDir successfully created replaced".replace("replaced", (ls testDir))
        write "[+] Deleting testDir"
        removeDirectory "testDir"
        if (-not (test-path "testDir")) {
            write "[+] test.txt successfully deleted"
        } else {
            throw "DirectoryNotDeletedException"
        }
    } else {
        throw "DirectoryNotCreatedException"
    }

    write "[+] Creating test.txt and testDir and copying test.txt to testDir"
    createFile "test.txt"; createDirectory "testDir"
    copyFile "test.txt" "testDir"
    if ((test-path test.txt) -and (test-path testDir/test.txt)) {
        echo "[+] File Successfully copied "
        removeFile "test.txt"; removeDirectory "testDir"
    }


}

<# Csharp environment handler #>
function testCsharpEnvironment {

}

<# Random Utility Functions #>
function windowsIdentityInfo {
    return [System.Security.Principal.WindowsIdentity]::GetCurrent()
}

function windowsIdentityName {
    return (windowsIdentityInfo).name
}

function windowsIdentityGroups {
    return (windowsIdentityInfo).groups 
}

function isAdminV1 {
    $user = windowsIdentityName
    if ((windowsIdentityInfo).groups -match "S-1-5-32-544") {
        write "[+] User $user is Admin."
    } else {
        write "[+] User $user is not Admin"
    }
}

function isAdminV2 {
    if (([Security.Principal.WindowsPrincipal](windowsIdentityInfo)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        echo "Admin: True"
    } else {
        echo "Admin: False"
    }
}

function samFile {
    ls hklm:/SAM
}

<# Docker Management #>
function set_docker_shell([String]$shell_type) {
    if ($shell_type -ne "cmd" -and $shell_type -ne "powershell") {
        throw "BadShellValue Exception"
    } elseif ($shell_type -eq "cmd") {
        docker-machine.exe env --shell $shell_type default
    } elseif ($shell_type -eq "powershell") {
        docker-machine.exe env --shell $shell_type default | invoke-expression
    } else {
        throw "Something went wrong!!!"
    }
}

<# Powershell utilities for gcloud-sdk #>
function stream_logs {
    gcloud app logs tail -s default 
}

function read_logs {
    gcloud app logs read
}

<# Powershell gulp functions #>
function install_gulp_dependencies ([string[]]$dependencies) {
    foreach ($dependency in $dependencies) {
        npm install --save $dependency
    }
}

<# 
    Collect all the processes every second
    Filter which ones are increasing
 #>
 function monitor_processes {
    $processes_data = @{}
    $current_processes = $null
    $programs_increasing = @()

    while ($true) {
        start-sleep -seconds 1
        $current_processes = get-process
        foreach ($process in $current_processes) {
            $process_id = ($process.id).toString()
            if ($processes_data.keys -contains $process_id) {
                $current_cpu = get_process_cpu_usage $process_id
                $process_name = get_process_name $process_id
                if ($current_cpu -gt ([double]($processes_data[$process_id]))) {
                    $processes_data[$process_id] = $current_cpu
                    $programs_increasing += ("Process Name: $process_name, Process_id: $process_id, Process_cpu: $current_cpu")
                }
            } else {
                start-sleep -seconds 1
                write (("[+] New process found ") + (get_process_name $process_id))
                $processes_data[$process_id] = (get_process_cpu_usage $process_id)
            }
        }

        write "[+] Showing processes increasing"
        write $programs_increasing
        $programs_increasing.clear()
    } 
 }

 function get_process_cpu_usage ($process_id) {
    $cpu_usage = ((gps).where{$_.id -eq $process_id}).cpu 
    return $cpu_usage
 }

 function get_process_name ($process_id) {
    return ((gps).where{$_.id -eq $process_id}).processname 
 }

 function show_bios {
    $computername = $env:COMPUTERNAME
    Get-WmiObject -class win32_bios -computername $computername
 }
 

