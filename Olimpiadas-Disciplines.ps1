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
$uri = "https://apis.codante.io/olympic-games/disciplines"
$headers = @{
    'Content-Type' = 'application/json'
    #'Authorization' = 'Bearer <MyTokenID>'
    'Accept' = 'application/json'
}

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

#Only enable when wanting to see data here
#$response.data

# Select the columns you want (e.g., 'id' and 'status')
$data = $response | Select-Object -ExpandProperty data | Select-Object id, name, pictogram_url, pictogram_url_dark, @{Name = 'DataCollectionDate'; Expression = { $collectionDateTime}}
#Note: Custom Column DataCollectionDate

#Only enable when wanting to see data here
#$data

####################################################################

#Write data to CSV FIles

$LiveFilePath = "c:\OlimpiadasOutput\Disciplines_Live.csv"

$HistoricalFilePath = "c:\OlimpiadasOutput\Disciplines_History.csv"

# Write Live Data to File
$data | Export-Csv -Path $LiveFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8
#Encoding Super important for Characters


# Write Historical Data to File
$data | Export-Csv -Path $HistoricalFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8  -Append
#Encoding Super important for Characters

####################################################################

#Write to SQL Server

#Truncate Live Table
Invoke-DbaQuery -SqlInstance micropc1 -Database Olimpiadas -Query 'EXECUTE Olimpiadas.dbo.usp_TruncateDisciplines;'

#Write Live Data to SQL Server
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table Disciplines  -Delimiter "|"

#Write Live Data to SQL Server (Historical Table)
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table DisciplinesHistory -Delimiter "|"