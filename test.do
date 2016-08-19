discard
adopath ++ "D:/lokal/soeptools/soepfitsclass"

local fix pber
use "${temp}`fix'", clear

soepfitsclass pber_kldb92, id(407,408) force

soepusemerge "//hume/rdc-gen/consolidated/soep-core/soep.v31_test/bepgen.dta" using "\\hume\rdc-gen\generations\soep-core\soep.v31_test\partial", clear verbose

quietly import delimited using "http://gitlab.soep.de/kwenzig/additionalmetadata/raw/master/templates/values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear

discard
adopath ++ "D:/lokal/soeptools/soepidvars"

use \\hume\soep-data\DATA\soep31_de\stata\zvp, clear
soepidvars, verbose
return list

discard
adopath ++ "D:/lokal/soeptools/soepidvars"

set more off
local usedir "\\hume\soep-data\DATA\soep31_de\stata\"
local files : dir `"`usedir'"' files "bd*.dta"
display `"`files'"'
local filesn : word count `files'
display "`filesn'"

set trace off
foreach file of local files {
	local fileurl "`usedir'/`file'"
	 use `fileurl', clear
	getfilename2 `fileurl'
	local root = "`r(root)'"
	soepidvars
	local ids_`root' = "`r(idvars)'"
	local roots = "`roots' `root'"
	display "`file': `ids_`root''"
}
clear
local filesn : word count `files'
set obs `filesn'
gen str dataset = ""
gen str idvars = ""
set trace off
forvalues i = 1/`filesn' {
	local dataset : word `i' of `roots'
	local idvars = "`ids_`dataset''"
	display "`dataset'"
	display `"`idvars'"'
	replace dataset = "`dataset'" in `i'
	replace idvars = "`idvars'" in `i'
}



        set more off                                                
        local usedir "\\hume\soep-data\DATA\soep31_de\stata\"       
        local files : dir `"`usedir'"' files "bd*.dta"                
        display `"`files'"'                                         
        foreach file of local files {       
                local fileurl "`usedir'/`file'"       
                use `fileurl', clear                   
                getfilename2 `fileurl'                
                local root = "`r(root)'"              
                soepidvars                            
                local ids_`root' = "`r(idvars)'"      
                local roots = "`roots' `root'"        
                display "`file': `ids_`root''"        
        }                                   
        clear                                    
        local filesn : word count `files'        
        set obs `filesn'                         
        gen str dataset = ""                     
        gen str idvars = ""                      
        forvalues i = 1/`filesn' {          
                local dataset : word `i' of `roots'   
                local idvars = "`ids_`dataset''"      
                replace dataset = "`dataset'" in `i'  
                replace idvars = "`idvars'" in `i'    
        }  

		
discard
adopath ++ "D:/lokal/soeptools/soepgenpre"

soepgenpre, version(v31_test) replace empty verbose

discard
adopath ++ "D:/lokal/soeptools/soepapplyvaluelabel"


sysuse auto, clear
soepapplyvaluelabel foreign mpg, id(1,16) language(en) utf2cp
fre foreign

local lblname t23,2
display "`lblname'"
capture label drop "`lblname'"
sysuse auto, clear
generate test 
local ids "12,3"
local ids : subinstr local ids "," "_"
display "`ids'"
foreach id in `ids' {
	display "`id'"
}

discard
adopath ++ "D:/lokal/soeptools/soeputf2cp"

*soeputf2cp using "https://gitlab.soep.de/kwenzig/additionalmetadata/raw/master/templates/values_templates.csv", topath(tmpdir) copy
*return list


discard
adopath ++ "D:/lokal/soeptools/soepapplyvaluelabel"


*sysuse auto, clear
*soepapplyvaluelabel foreign mpg, id(1,16) language(de) utf2cp

discard
adopath ++ "D:/lokal/soeptools/soepfitsclass"

discard
adopath ++ "D:/lokal/soeptools/soepmergeclass"

discard
adopath ++ "D:/lokal/soeptools/soepinfra2ganze"

discard
adopath ++ "D:/lokal/soeptools/soepinfra2com"

discard
adopath ++ "D:/lokal/soeptools/soepkldb92mps"

discard
adopath ++ "D:/lokal/soeptools/soepdropchar"
