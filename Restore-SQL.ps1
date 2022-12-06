# Task 2 by Julius Santos ID: 010532309

# Import SQLServer Module
if (Get-Module -Name sqlps) { Remove-Module sqlps }
Import-Module -Name SqlServer

# Setting Name variables
$sqlServerName = "Your\Server"
$DBName = 'ExampleDB'

#Exception Handling
try 
{
    # Checking existince of CliendDB Database 
    $sqlServerObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqlServerName
    $existingDatabase = $sqlServerObject.databases
    if ($existingDatabase.Name -like $DBName) {
        #Dropping Database if it exists
        Write-Host -ForegroundColor Green "[SQL]: $($DBName) Already Exists"
        $sqlServerObject.KillAllProcesses($DBName)
        Invoke-Sqlcmd -ServerInstance $sqlServerName  -database master -query "DROP DATABASE [ClientDB]" -ErrorAction stop
        Write-Host -ForegroundColor Green "[SQL]: $($DBName) deleted"
        #Re-adding Database after drop
        $databaseObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServerObject, $DBName
        $databaseObject.Create()
        Write-Host -ForegroundColor Green "[SQL]: $($DBName) was re-added"
    } else {
        #Adding database if it does not exist
        Write-Host -ForegroundColor Green "[SQL]: $($DBName) does not exist" 
        $databaseObject = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServerObject, $DBName
        $databaseObject.Create()
        Write-Host -ForegroundColor Green "[SQL]: $($DBName) was added"
    } 
}
catch {
    Write-Host -ForegroundColor Red "[SQL]: An error occured while adding Database"
} 

#Exception Handling
try 
{
    # Adding Table to DB 
    Invoke-Sqlcmd -ServerInstance $sqlServerName -Database $DBName -InputFile $PSScriptRoot\Create_Example_Table.sql -ErrorAction stop
    Write-Host -ForegroundColor Green "[SQL]: Example_Table was added"
}
catch {
    Write-Host -ForegroundColor Red "[SQL]: An Error occured while adding Table"
}

#Variables for Table name and  new data
$table = 'dbo.Example_Table'
try {
    #Importing data from .csv
    Import-Csv $PSScriptRoot\NewPeopleData.csv | ForEach-Object {Invoke-Sqlcmd -Database $DBName -ServerInstance $sqlServerName `
        -Query "INSERT INTO $table (first_name, last_name, city, county, zip, officePhone, mobilePhone) VALUES ('$($_.first_name)','$($_.last_name)','$($_.city)','$($_.county)','$($_.zip)','$($_.officePhone)','$($_.mobilePhone)')"}
    Write-Host -ForegroundColor Green "[SQL]: .csv Import Complete"
}
catch 
{
    Write-Host -ForegroundColor Red "An Error Occured while importing .csv file"
}



