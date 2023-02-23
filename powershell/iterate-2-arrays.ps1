<# process 2 arrays x,y #>

$ar1=[System.Collections.Arraylist]@() 
$ar2=[System.Collections.Arraylist]@() 

$ar1 = get-content file1
$ar2 = get-content file2

# basic
<#
foreach ($outer in $ar1) {
  foreach ($inner in $ar2) {
    Write-Host "$outer $inner"
  }
}
#>

# 32x32 = 1024

# sort by lname and cap 1st letter
# REF: https://stackoverflow.com/questions/22694582/capitalize-the-first-letter-of-each-word-in-a-filename-with-powershell

foreach ($outer in $ar1) {
  foreach ($inner in $ar2 |sort-object) {
    Write-Host (Get-Culture).TextInfo.ToTitleCase($outer) (Get-Culture).TextInfo.ToTitleCase($inner)
  }
}

# A different way - go through 2 arrays and 1:1 index the output
# REF: https://www.reddit.com/r/PowerShell/comments/118bfwk/trackingiterating_multiple_array_elements_in/

# sort by last name and match cur entry with corresponding entry at same index # in the first array
foreach ($thisperson in $ar2 |sort-object) {
    $index = $ar2.IndexOf($thisperson)
    Write-Host $ar1[$index]"married into the $thisperson family"
}

<# linux show 2 files side by side
paste file1 file2 |column -t
jerry      jones
barb       smith
dave       bechtel
joe        gauntt
berferd    stafford
sue        johnson
holly      reeves
ivan       welch
tim        zoden
sarah      mcinteer
shmoo      cleverlastname
gleeb      coltrane
matt       plissken
fox        duncan
moon       sandpiper
firstname  unusuallastname
sally      hovenzoot
rick       blifterfargen
ingrid     faffergnugen
ophelia    mogendaven
paul       philistenbargen
peter      whammityvoodle
james      cheapenstein
mark       frozenbork
luke       noodlebom
john       wangazord
kelly      jackson
anna       frobisher
elizabeth  treehugger
obadiah    goofibomber
river      yakkitysax
ophelia    doodlebooger

# Result of this script:
dave married into the bechtel family
rick married into the blifterfargen family
james married into the cheapenstein family
shmoo married into the cleverlastname family
gleeb married into the coltrane family
ophelia married into the doodlebooger family
fox married into the duncan family
ingrid married into the faffergnugen family
anna married into the frobisher family
mark married into the frozenbork family
joe married into the gauntt family
obadiah married into the goofibomber family
sally married into the hovenzoot family
kelly married into the jackson family
sue married into the johnson family
jerry married into the jones family
sarah married into the mcinteer family
ophelia married into the mogendaven family
luke married into the noodlebom family
paul married into the philistenbargen family
matt married into the plissken family
holly married into the reeves family
moon married into the sandpiper family
barb married into the smith family
berferd married into the stafford family
elizabeth married into the treehugger family
firstname married into the unusuallastname family
john married into the wangazord family
ivan married into the welch family
peter married into the whammityvoodle family
river married into the yakkitysax family
tim married into the zoden family

#>
