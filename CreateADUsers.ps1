

function Get-Generator{

Write-Host 'This script will require you to input variable information to work properly.'

    [int]$NumberUser_int = Read-Host '1) Enter the number of users to create'
    $NameFile_str = Read-Host '2) Enter the file path for the txt file containing the user names'
    $SurnameFile_str = Read-Host '3) Enter the file path for the txt file containing the user surnames'
    $DepartmentFile_str = Read-Host '4) Enter the file path for the txt file containing your AD organizational units names'
    $Domain_str = Read-Host '5) Enter your domain name, e.g. mydomain.com'

    if ($NumberUser_int -gt 1){

            if ($NameFile_str){

                if ($SurnameFile_str){

                    if ($DepartmentFile_str){

                        if ($Domain_str){

                            Write-Host "All variable sets have been included, initiating user generation."
                        
                            $Name_Array = Get-Names($NameFile_str)
    
                            $Surname_Array = Get-Surnames($SurnameFile_str)
    
                            $Departments_Array = Get-Deparments($DepartmentFile_str)
                                    
                            Get-GenerateUsers $NumberUser_int $Name_Array $Surname_Array $Departments_Array $Domain_str

                        }        
                        else {
                            Write-Host "ERROR! No Domain Name has been set."
                            exit
                        }
                    }        
                    else {
                        Write-Host "ERROR! No file path for deparments has been set."
                        exit
                    }


                }
                else {
                    Write-Host "ERROR! No file path for surnames has been set."
                    exit
                }

            }

            else {
                Write-Host "ERROR! No file path for names has been set."
                exit
            }
    }
    else 
    {
        Write-Host "ERROR! No number for users has been set."
        exit
    }


}

function Get-Names{
    param(
        [Parameter(Mandatory = $true)] [string] $name_filepath
    )


    $NameArray = Get-Content $name_filepath
    Write-Host "Step 1, user names file has been loaded."

    return $NameArray

}

function Get-Surnames{
    param(
        [Parameter(Mandatory = $true)] [string] $surname_filepath
    )

    $SurnameArray = Get-Content $surname_filepath
    Write-Host "Step 2, user surnames file has been loaded."

    return $SurnameArray

}

function Get-Deparments{
    param(
        [Parameter(Mandatory = $true)] [string] $dept_filepath
    )

    $DeptArray = Get-Content $dept_filepath
    Write-Host "Step 3, user OU file has been loaded."

    return $DeptArray

}

function Get-GenerateUsers{
    param(
        [Parameter(Mandatory = $true)] [int] $usermax,
        [Parameter(Mandatory = $true)] [array] $namelist,
        [Parameter(Mandatory = $true)] [array] $surnamelist,
        [Parameter(Mandatory = $true)] [array] $OUlist,
        [Parameter(Mandatory = $true)] [string] $Domain
    )

        $AD_FullName = ''
        $AD_GivenName = ''
        $AD_SurnameName = ''
        $AD_AccountName = ''
        $AD_PrincipalName = ''
        $AD_PathAddress = ''
        $AD_Password = ''
        $UserBoundary = $namelist.Length - 1
        $SurnameBoundary = $surnamelist.Length - 1
        $OUBoundary = $OUlist.Length -1

        for ($loop = 0; $loop -lt $usermax; $loop++) {

            $tmp_randomname = Get-Random -Minimum 0 -Maximum $UserBoundary
            $tmp_randomsurname = Get-Random -Minimum 0 -Maximum $SurnameBoundary
            $tmp_randomou = Get-Random -Minimum 0 -Maximum $OUBoundary

            $AD_FullName = $namelist[$tmp_randomname] + " " + $surnamelist[$tmp_randomsurname]
            $AD_GivenName = $namelist[$tmp_randomname]
            $AD_SurnameName = $surnamelist[$tmp_randomsurname]
            $AD_AccountName = $AD_GivenName.Substring(0,1) + $AD_SurnameName + [string]$loop
            $AD_PrincipalName = $AD_AccountName + "@" + $Domain
            $AD_PathAddress = "OU=" + $OUlist[$tmp_randomou] + "," + "DC=" + $Domain.Split(".")[0] + "," + "DC=" + $Domain.Split(".")[1]
            $AD_Password = Get-RandomPassword 14 2 2 2 1
            
            Write-Host "Step 4, User number: " [string]$loop " has been created"
            Get-CreateUser $AD_FullName $AD_GivenName $AD_SurnameName $AD_AccountName $AD_PrincipalName $AD_PathAddress $AD_Password
            # Uncomment the following line if you wish to see user data on screen
            #Write-Host $AD_FullName " " $AD_GivenName " " $AD_SurnameName " " $AD_AccountName " " $AD_PrincipalName " " $AD_PathAddress " " $AD_Password
            

            
        }
}

function Get-RandomPassword {
    param (
        [Parameter(Mandatory)]
        [ValidateRange(4,[int]::MaxValue)]
        [int] $length,
        [int] $upper = 1,
        [int] $lower = 1,
        [int] $numeric = 1,
        [int] $special = 1
    )
    if($upper + $lower + $numeric + $special -gt $length) {
        throw "number of upper/lower/numeric/special char must be lower or equal to length"
    }
    $uCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $lCharSet = "abcdefghijklmnopqrstuvwxyz"
    $nCharSet = "0123456789"
    $sCharSet = "/*-+,!?=()@;:._"
    $charSet = ""
    if($upper -gt 0) { $charSet += $uCharSet }
    if($lower -gt 0) { $charSet += $lCharSet }
    if($numeric -gt 0) { $charSet += $nCharSet }
    if($special -gt 0) { $charSet += $sCharSet }
    
    $charSet = $charSet.ToCharArray()
    $rng = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $bytes = New-Object byte[]($length)
    $rng.GetBytes($bytes)
 
    $result = New-Object char[]($length)
    for ($i = 0 ; $i -lt $length ; $i++) {
        $result[$i] = $charSet[$bytes[$i] % $charSet.Length]
    }
    $password = (-join $result)
    $valid = $true
    if($upper   -gt ($password.ToCharArray() | Where-Object {$_ -cin $uCharSet.ToCharArray() }).Count) { $valid = $false }
    if($lower   -gt ($password.ToCharArray() | Where-Object {$_ -cin $lCharSet.ToCharArray() }).Count) { $valid = $false }
    if($numeric -gt ($password.ToCharArray() | Where-Object {$_ -cin $nCharSet.ToCharArray() }).Count) { $valid = $false }
    if($special -gt ($password.ToCharArray() | Where-Object {$_ -cin $sCharSet.ToCharArray() }).Count) { $valid = $false }
 
    if(!$valid) {
         $password = Get-RandomPassword $length $upper $lower $numeric $special
    }
    return $password
}

function Get-CreateUser{
    param(
        [Parameter(Mandatory = $true)] [string] $l_FullName,
        [Parameter(Mandatory = $true)] [string] $l_GivenName,
        [Parameter(Mandatory = $true)] [string] $l_SurnameName,
        [Parameter(Mandatory = $true)] [string] $l_AccountName,
        [Parameter(Mandatory = $true)] [string] $l_PrincipalName,
        [Parameter(Mandatory = $true)] [string] $l_PathAddress,
        [Parameter(Mandatory = $true)] [string] $l_Password
    )

    New-ADUser -Name $l_FullName -GivenName $l_GivenName -Surname $l_SurnameName -SamAccountName $l_AccountName -UserPrincipalName $l_PrincipalName -Path $l_PathAddress -AccountPassword(ConvertTo-SecureString $l_Password -AsPlainText -force) -passThru -Enabled $true

}

Get-Generator