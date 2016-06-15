

<#
.Synopsis
   Creates a new archive from a file
.DESCRIPTION
   Creates a new archive with the contents from a file. This function relies on the
   .NET Framework 4.5. On windwows Server 2012 R2 Core you can install it with
   Install-WindowsFeature Net-Framework-45-Core
.EXAMPLE
   New-ArchiveFromFile -Source c:\test\test.txt -Destination c:\test.zip
#>
function New-ArchiveFromFile
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=0)]
        [string]
        $Source,
        # Param2 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$false,
                   Position=1)]
        [string]
        $Destination
    )
    Begin
    {
        [System.Reflection.Assembly]::LoadWithPartialName(“System.IO.Compression.FileSystem”) | Out-Null
    }
    Process
    {
        try
        {
            Write-Verbose “Creating archive $Destination….”
            $zipEntry = “$Source“ | Split-Path -Leaf
            $zipFile = [System.IO.Compression.ZipFile]::Open($Destination, ‘Update’)
            $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipfile,$Source,$zipEntry,$compressionLevel)
            Write-Verbose “Created archive $destination.”
        }
        catch [System.IO.DirectoryNotFoundException]
        {
            Write-Host “ERROR: The source $source does not exist!” -ForegroundColor Red
        }
        catch [System.IO.IOException]
        {
            Write-Host “ERROR: The file $Source is in use or $destination already exists!” -ForegroundColor Red
        }
        catch [System.UnauthorizedAccessException]
        {
            Write-Host “ERROR: You are not authorized to access the source or destination” -ForegroundColor Red
        }
    }
    End
    {
        $zipFile.Dispose()
    }
}
