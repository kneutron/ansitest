<# #>

[array]$mos = Write-Output  Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
$mos

$year = [System.Collections.ArrayList]@()::new
$Jan = [System.Collections.ArrayList]@()::new
$Feb = [System.Collections.ArrayList]@()::new
$Mar = [System.Collections.ArrayList]@()::new
$Apr = [System.Collections.ArrayList]@()::new
$May = [System.Collections.ArrayList]@()::new
$Jun = [System.Collections.ArrayList]@()::new
$Jul = [System.Collections.ArrayList]@()::new
$Aug = [System.Collections.ArrayList]@()::new
$Sep = [System.Collections.ArrayList]@()::new
$Oct = [System.Collections.ArrayList]@()::new
$Nov = [System.Collections.ArrayList]@()::new
$Dec = [System.Collections.ArrayList]@()::new

cd

$Jan = ( import-csv 2023-Jan.csv )
$Feb = ( import-csv 2023-Feb.csv )
$Mar = ( import-csv 2023-Mar.csv )
$Apr = ( import-csv 2023-Apr.csv )
$May = ( import-csv 2023-May.csv )
$Jun = ( import-csv 2023-Jun.csv )
$Jul = ( import-csv 2023-Jul.csv )
$Aug = ( import-csv 2023-Aug.csv )
$Sep = ( import-csv 2023-Sep.csv )
$Oct = ( import-csv 2023-Oct.csv )
$Nov = ( import-csv 2023-Nov.csv )
$Dec = ( import-csv 2023-Dec.csv )

$output = @() # THIS BREAKS if we use [System.Collections.ArrayList]@()::new

# REF: https://stackoverflow.com/questions/20340525/evaluate-a-variable-within-a-variable-in-powershell
#"eval" DayDetails = $Jan (put all the Jan data in)

foreach ($thismo in $mos) {
#    $thismo # DEBUGG
    $tmpobj = [PSCustomObject]@{

    # xxx TODO comment as needed - output fields for csv
                    'Month'                = $thismo
                    'DayDetails'            = $(Get-Variable -Name $thismo -ValueOnly)
    } # customobj

    $output += $tmpobj

} # foreach

$output
Write-Host ""
$output |where-object { $_.DayDetails -match 'Fr=13' } |select-object -Property Month,{$_.daydetails.Fr}

Write-Host ""
$output |where-object { $_.DayDetails -match 'Fr=13' } |select-object -Property Month,{$_.daydetails.Fr[1]}

<#
Month $_.daydetails.Fr[1]
----- -------------------
Jan   13
Oct   13
#>

#$output.daydetails |where-object Fr -eq 13 

<#
Su : 8
Mo : 9
Tu : 10
We : 11
Th : 12
Fr : 13
Sa : 14

Su : 8
Mo : 9
Tu : 10
We : 11
Th : 12
Fr : 13
Sa : 14

$output |oss |select-string Fr=13

Jan   {@{Su=1; Mo=2; Tu=3; We=4; Th=5; Fr=6; Sa=7}, @{Su=8; Mo=9; Tu=10; We=11; Th=12; Fr=13; Sa=14}, 
@{Su=15;…
Oct   {@{Su=1; Mo=2; Tu=3; We=4; Th=5; Fr=6; Sa=7}, @{Su=8; Mo=9; Tu=10; We=11; Th=12; Fr=13; Sa=14},
@{Su=15;…


$output |where-object { $_.DayDetails -match 'Fr=13' }    

Month DayDetails
----- ----------
Jan   {@{Su=1; Mo=2; Tu=3; We=4; Th=5; Fr=6; Sa=7}, @{Su=8; Mo=9; Tu=10; We=11; Th=12; Fr=13; Sa=14}, @{Su=15… 
Oct   {@{Su=1; Mo=2; Tu=3; We=4; Th=5; Fr=6; Sa=7}, @{Su=8; Mo=9; Tu=10; We=11; Th=12; Fr=13; Sa=14}, @{Su=15… 


$output |where-object { $_.DayDetails -match 'Fr=13' } |select Month

Month
-----
Jan
Oct


$output |where-object { $_.DayDetails -match 'Fr=13' } |select-object -Property Month,{$_.daydetails.Fr}

Month $_.daydetails.Fr
----- ----------------
Jan   {6, 13, 20, 27…}
Oct   {6, 13, 20, 27…}


$output.daydetails.Fr |where-object { $_ -match 13 }
13
13

#>

<#
$Jan = ( get-content 2023-Jan.csv )
$Feb = ( get-content 2023-Feb.csv )
$Mar = ( get-content 2023-Mar.csv )
$Apr = ( get-content 2023-Apr.csv )
$May = ( get-content 2023-May.csv )
$Jun = ( get-content 2023-Jun.csv )
$Jul = ( get-content 2023-Jul.csv )
$Aug = ( get-content 2023-Aug.csv )
$Sep = ( get-content 2023-Sep.csv )
$Oct = ( get-content 2023-Oct.csv )
$Nov = ( get-content 2023-Nov.csv )
$Dec = ( get-content 2023-Dec.csv )
#>