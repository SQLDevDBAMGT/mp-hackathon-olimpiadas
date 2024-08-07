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

#This is a script to take the events and put them into a file.  There are one or many competitors for each event.

#Get Current Date
$collectionDateTime = Get-Date ([datetime]::UtcNow) -Format o

####################################################################

#Address: https://apis.codante.io/olympic-games/events

#Clear Variables due to issues with persisting
Clear-Variable -Name CurrentPageEvents -Scope Global
Clear-Variable -Name LastPageEvents -Scope Global
Clear-Variable -Name DateToSearchEvents -Scope Global
Clear-Variable -Name FullResponsesEvents1 -Scope Global
Clear-Variable -Name response -Scope Global


#Establish Current page, for the initial and looped calls
$CurrentPageEvents = 1

#Establish Date to search
$DateToSearchEvents = "2024-08-07"
####################################################################



# Define the API endpoint and headers
$uri = "https://apis.codante.io/olympic-games/events?date="+ $DateToSearchEvents + "&page=" + $CurrentPageEvents
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

#$TotalRecordsEvents = $response.meta.total
#Enable when wanting to see data on screen
#$TotalRecords

$LastPageEvents = $response.meta.last_page
#Enable when wanting to see data on screen
#$LastPageEvents

Clear-Variable -Name FullResponsesEvents1 -Scope Global

####################################################################

#use a while loops to get all pages (ensuring only to go to the last page)

while ($CurrentPageEvents -lt $LastPageEvents+1)
    {
        # Define the API endpoint and headers
        $uri = "https://apis.codante.io/olympic-games/events?date="+ $DateToSearchEvents + "&page=" + $CurrentPageEvents
        $headers = @{
            'Content-Type' = 'application/json'
            #'Authorization' = 'Bearer <MyTokenID>'
            'Accept' = 'application/json'
        }

        # Make the API call and retrieve the data
        $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers

        #Call  and Get Meta Information (Current Page)
        #$response.meta.current_page
        

        $FullResponsesEvents1 += $Response.data | Select-Object id, day, discipline_name, discipline_pictogram, name, venue_name, event_name, detailed_event_name, start_date, end_date, status, is_medal_event, is_live, gender_code, @{Name = 'DataCollectionDate'; Expression = { $collectionDateTime}} -ExcludeProperty competitors


        #Increment Page Counter
        $CurrentPageEvents++

        #Show CUrrent page if needed
        #$CurrentPageEvents
    }


#Only enable when wanting to see the data on screen
#$FullResponsesEvents1


####################################################################

#Write data to files
$LiveFilePath = "c:\OlimpiadasOutput\Events_Live.csv"

$HistoricalFilePath = "c:\OlimpiadasOutput\Events_History.csv"

# Write Live Data to File
$FullResponsesEvents1 | Export-Csv -Path $LiveFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8
#Encoding Super important for Characters


# Write Historical Data to File
$FullResponsesEvents1 | Export-Csv -Path $HistoricalFilePath -NoTypeInformation -Delimiter "|" -Encoding UTF8 -Append
#Encoding Super important for Characters


#Clear Variables due to issues with persisting
Clear-Variable -Name CurrentPageEvents -Scope Global
Clear-Variable -Name LastPageEvents -Scope Global

####################################################################

#Write to SQL Server

#Truncate Live Table
Invoke-DbaQuery -SqlInstance micropc1 -Database Olimpiadas -Query 'EXECUTE Olimpiadas.dbo.usp_TruncateEvents;'

#Write Live Data to SQL Server
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table Events -Delimiter "|"

#Write Live Data to SQL Server (Historical Table)
import-DBACsv -Path $LiveFilePath -SqlInstance MicroPC1 -Database Olimpiadas -Table EventsHistory -Delimiter "|"

#Clear Variables due to issues with persisting
Clear-Variable -Name CurrentPageEvents -Scope Global
Clear-Variable -Name LastPageEvents -Scope Global
Clear-Variable -Name DateToSearchEvents -Scope Global
Clear-Variable -Name FullResponsesEvents1 -Scope Global
Clear-Variable -Name response -Scope Global
