<#
############################################
CREATED BY: SQLDevDBA 
CREATED DATE: 2024-08-04
CREATED FOR:  Twitch LiveStream Demo of Codante IO API 
Questions?  Contact:
https://SQLDevdba.com
https://twitch.tv/SQLDevDBA
https://youtube.com/@SQLDevDBA
############################################
#>

#Global Parameters
$collectionDateTime = Get-Date ([datetime]::UtcNow) -Format o

####################################################################

# Define the API endpoint and headers
$uri = "https://apis.codante.io/olympic-games/countries"
$headers = @{
    'Content-Type' = 'application/json'
    #'Authorization' = 'Bearer <MyTokenID>'
    'Accept' = 'application/json'
}

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$responses = $response.data


####################################################################

#####Page 2

$uri = "https://apis.codante.io/olympic-games/countries?page=2"

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$responses += $response.data
####################################################################

#####Page 3

$uri = "https://apis.codante.io/olympic-games/countries?page=3"

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$responses += $response.data
####################################################################

#####Page 4

$uri = "https://apis.codante.io/olympic-games/countries?page=4"

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$responses += $response.data
####################################################################

#####Page 5

$uri = "https://apis.codante.io/olympic-games/countries?page=5"

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

$responses += $response.data
####################################################################

#Only enable when wanting to see data here
#$responses


# Select the columns you want (e.g., 'id' and 'status')
$data = $responses | Select-Object | Select-Object id, name, continent, flag_url, gold_medals, silver_medals, bronze_medals, total_medals, rank, rank_total_medals, @{Name = 'DataCollectionDate'; Expression = { $collectionDateTime}}
#Note: Custom Column DataCollectionDate

#Only enable when wanting to see data here
#$data


####################################################################

#Write data to CSV files

$LiveFilePath = "c:\OlimpiadasOutput\Countries_Live.csv"

$HistoricalFilePath = "c:\OlimpiadasOutput\Countries_History.csv"

# Write Live Data to File
$data | Export-Csv -Path $LiveFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8
#Encoding Super important for Characters


# Write Historical Data to File
$data | Export-Csv -Path $HistoricalFilePath -NoTypeInformation -Delimiter "|"  -Encoding UTF8 -Append
#Encoding Super important for Characters


####################################################################

#Write to SQL Server


#Truncate Live Table
Invoke-DbaQuery -SqlInstance micropc1 -Database Olimpiadas -Query 'EXECUTE Olimpiadas.dbo.usp_TruncateCountries;'

#Write Live Data to SQL Server
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table Countries  -Delimiter "|"

#Write Live Data to SQL Server (Historical Table)
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table CountriesHistory -Delimiter "|"
