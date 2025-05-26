function Format-ExecutionTime {
    param (
        [Parameter(Mandatory=$true)]
        [System.TimeSpan]$ExecutionTime
    )

    switch ($ExecutionTime) {
        { $_.TotalMinutes -gt 1 } { 
            '{0} min, {1} sec' -f [math]::Floor($_.Minutes), $_.Seconds
            break
        }
        { $_.TotalSeconds -gt 1 } { 
            '{0:0.00} sec' -f $_.TotalSeconds
            break
        }
        default { 
            '{0:N0} ms' -f $_.TotalMilliseconds
        }
    }
}