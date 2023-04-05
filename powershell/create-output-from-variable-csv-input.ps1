<# Create an output csv based on multiple variable input CSV files 
REF: https://www.reddit.com/r/PowerShell/comments/12bxnmq/multiple_csv_filenames_used_as_columns_of_new_csv/

Mod for powershell on OSX, should also run on Linux
#>

# Define the path to the directory containing the text lists
$directoryPath = "$HOME/csv-var-inputs" # "C:\path\to\directory"
$Outfile = "$HOME/variable-table-output.csv"

# Get a list of all the csv files in the directory
$listPaths = Get-ChildItem $directoryPath -Filter *.csv | Select-Object -ExpandProperty FullName

# Create an empty hashtable to store the names
$names = @{}

# Loop through each list and add the names to the hashtable
foreach ($listPath in $listPaths) { 

# Get the names from the current list 
    $listNames = Get-Content $listPath

# Add each name to the hashtable
    foreach ($name in $listNames) {

        if ($names.ContainsKey($name)) {
# If the name already exists in the hashtable, add the list name to the existing entry
            $names[$name] += ", $($listPath |Split-Path -Leaf)"
#            -Leaf
#            Indicates that this cmdlet returns only the last item or container in the path. 
#            For example, in the path C:\Test\Logs\Pass1.log, it returns only Pass1.log.            
        } else {
# If the name doesn't exist in the hashtable, create a new entry with the list name
            $names[$name] = $($listPath |Split-Path -Leaf)
        } # if containskey
    } # foreach name
} # foreach input csv

# Convert the hashtable to a table and output to a CSV file
$table = New-Object System.Data.DataTable

# Add columns for the "Name" and each list
$table.Columns.Add("Name", [string]) 

foreach ($listPath in $listPaths) { 
    $columnName = $($listPath |Split-Path -Leaf) 
    $column = New-Object System.Data.DataColumn($columnName, [string]) 
    $table.Columns.Add($column) 
}

# Add rows to the table for each name
foreach ($name in $names.Keys) { 
    $row = $table.NewRow() 
    $row["Name"] = $name

    foreach ($listPath in $listPaths) {
        $columnName = $($listPath |Split-Path -Leaf)

        if ($names[$name] -like "*$columnName*") {
            $row[$columnName] = "X"
        }
    }
    $table.Rows.Add($row)
}

$tablesort = $table |Sort-Object Name 
$tablesort |Format-Table
$tablesort |Export-Csv $Outfile -NoTypeInformation
ls -lh $Outfile

<#
Example output:

Name   DVDs.csv hats.csv pants.csv shirts.csv
----   -------- -------- --------- ----------
Bob                      X         X
Jane                     X         X
Mary   X        X        X         X
Paul   X                 X         
Peter  X                 X         X
Sam             X                  
Ted             X        X         X
Trevor          X                  

#>