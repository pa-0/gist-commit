(Invoke-RestMethod "https://api.github.com/users/powershell/repos?per_page=100") | 
    select html_url,
        name,
        open_issues_count,
        @{
            n='updatedDaysAgo'
            e={
                $u=(get-date)-(get-date($_.pushed_at))
                [convert]::ToDecimal($u.totaldays.tostring("N2"))
              }
         } | Where {$_.updatedDaysAgo -lt 2} | sort updatedDaysAgo