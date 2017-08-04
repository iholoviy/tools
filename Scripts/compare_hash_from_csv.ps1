$file=Get-ChildItem -Path e:\ | % { $_.FullName }
foreach-Object {
Get-FileHash -Path $file
} | Export-Csv C:\Users\Administrator\Downloads\sha256_beforeRestore.csv -Append


$file=Get-ChildItem -Path e:\ | % { $_.FullName }
foreach-Object {
Get-FileHash -Path $file
} | Export-Csv C:\Users\Administrator\Downloads\sha256_afterRestore.csv -Append


$beforeRestore=Import-Csv C:\Users\Administrator\Downloads\sha256_beforeRestore.csv
$afterRestore=Import-Csv C:\Users\Administrator\Downloads\sha256_afterRestore.csv

if(Compare-Object -ReferenceObject $beforeRestore -DifferenceObject $afterRestore)
{"files are different"}
Else {"Files are the same"}
