* Author: Robert Picard
* http://www.statalist.org/forums/forum/general-stata-discussion/general/1291200-how-do-i-delete-all-characteristics-from-a-dataset?p=1291203#post1291203

program define soepdropchar

    version 9.2
    syntax [varlist] , [Dataset only]
    
    local vlist `varlist'
    
    if "`dataset'" ~= "" {
        local vlist _dta `vlist'
        if "`only'" != "" local vlist "_dta"
    }
    
    foreach v in `vlist' {
        local ilist: char `v'[]
        foreach i in `ilist' {
            char `v'[`i']
        }
    }
end
