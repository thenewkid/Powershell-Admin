<# Exploring the depths of powershell #>

<# 1. List multiple ways to extract a service by name #>
<# 2. Benchmark them #>
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
        if ($_.name -eq $serviceName)
            write $_
    }
}

function serviceByNameV4([String]$serviceName) {
    foreach ($service in (get-service))
}

function testGetService {
    write "[+] Measuring serviceByNameV1"
    measure-command { serviceByNameV1 }
    
    write "[+] Measuring serviceByNameV2"
    measure-command { serviceByNameV2 }
    
    write "[+] Measuring serviceByNameV3"
    measure-command { serviceByNameV3 }

    write "[+] Measuring serviceByNameV4"
    measure-command { serviceByNameV4 }
}

<# Program Execution [Start] #>
function main {
    testGetService
}

main