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

#This is a script to take the competitors for each event and put them into a file.  There are one or many competitors for each event.

#Get Current Date
$collectionDateTime = Get-Date ([datetime]::UtcNow) -Format o

####################################################################

#Address: https://apis.codante.io/olympic-games/events



#Establish Current page, for the initial and looped calls
$currentpage = 1

#Establish Date to search
$DateToSearch = "2024-08-07"
####################################################################

# Define the API endpoint and headers
$uri = "https://apis.codante.io/olympic-games/events?date="+ $DateToSearch + "&page=" + $currentpage
$headers = @{
    'Content-Type' = 'application/json'
    #'Authorization' = 'Bearer <MyTokenID>'
    'Accept' = 'application/json'
}

# Make the API call and retrieve the data
$response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

#Call once and Get Meta Information
#Enable when wanting to see data on screen
$response.meta

$TotalRecords = $response.meta.total
#Enable when wanting to see data on screen
#$TotalRecords

$LastPage = $response.meta.last_page
#Enable when wanting to see data on screen
#$LastPage

####################################################################

#use a while loops to get all pages (ensuring only to go to the last page)

while ($currentpage -lt $lastpage+1)
    {
        # Define the API endpoint and headers
        $uri = "https://apis.codante.io/olympic-games/events?date="+ $DateToSearch + "&page=" + $currentpage
        $headers = @{
            'Content-Type' = 'application/json'
            #'Authorization' = 'Bearer <MyTokenID>'
            'Accept' = 'application/json'
        }

        # Make the API call and retrieve the data
        $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

        #Call  and Get Meta Information (Current Page)
        #$response.meta.current_page

        
        # Create a custom object combining fields from parent and child nodes
        $customData = $response.data | ForEach-Object {
            $Events = $_ #ParkLands
            $_.competitors | ForEach-Object { #rides
                [PSCustomObject]@{
                    #Event Fields (These are used to relate the competitor fields BACK to the events
                    'event_id' = $Events.id
                    'event_discipline_name' = $Events.discipline_name
                    #Competitor Fields
                    #'country_id' = $_.country_id #CountryID no es, es el nombre que sale
                    'country_name' = $_.country_id #CountryID no es, es el nombre que sale
                    'country_flag_url' = $_.country_flag_url
                    'competitor_name' = $_.competitor_name
                    'position' = $_.position
                    'result_position' = $_.result_position
                    'result_winnerLoserTie' = $_.result_winnerLoserTie
                    'result_mark' = $_.result_mark
                    'DataCollectionDate' = $collectionDateTime
                }
            }
        }

        #Append this interations data to FullResponses holder
        $FullResponses += $customData

        #Increment Page CCounter
        $currentpage++
    }

#Only enable when wanting to see the data on screen
#$FullResponses

####################################################################

#Write data to files
$LiveFilePath = "c:\OlimpiadasOutput\Competitors_Live.csv"

$HistoricalFilePath = "c:\OlimpiadasOutput\Competitors_History.csv"

# Write Live Data to File
$FullResponses | Export-Csv -Path $LiveFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8
#Encoding Super important for Characters


# Write Historical Data to File
$FullResponses | Export-Csv -Path $HistoricalFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8 -Append
#Encoding Super important for Characters

####################################################################

#Write to SQL Server

#Truncate Live Table
Invoke-DbaQuery -SqlInstance micropc1 -Database Olimpiadas -Query 'EXECUTE Olimpiadas.dbo.usp_TruncateCompetitors;'

#Write Live Data to SQL Server
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table Competitors  -Delimiter "|"

#Write Live Data to SQL Server (Historical Table)
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table CompetitorsHistory -Delimiter "|"


#Clear Variables due to issues with persisting

Clear-Variable -Name CurrentPage -Scope Global
Clear-Variable -Name LastPage -Scope Global
Clear-Variable -Name DateToSearch -Scope Global
Clear-Variable -Name FullResponses -Scope Global


