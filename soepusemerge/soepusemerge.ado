/*-------------------------------------------------------------------------------
  soepusemerge.ado: Open a template file and integrate variables from related files

    Copyright (C) 2016  Knut Wenzig (kwenzig@diw.de)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------*/
*! soepusemerge.ado: Open a template file and integrate variables from related files
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.11 27 September 2016 - require keyvars of type long
*! version 0.1 13 April 2016 - initial release

program define soepusemerge , nclass
	version 13
	syntax anything(name=pathwfile) using/ , clear [keyvars(namelist) verbose]

* check whether getfilename is installed
quietly capture findfile getfilename2.ado
if "`r(fn)'" == "" {
         di as txt "package getfilename2 needs to be installed first;"
         di as txt "use -ssc install getfilename2- to do that"
         exit 498
}
	
	
* display parameters
if "`verbose'"=="verbose" {
	display `"syntax-pathwfile:`pathwfile'"'
	display "syntax-using:`using'"
	display "syntax-keyvars:`keyvars'"
	display "syntax-clear:`clear'"
	display "syntax-verbose:`verbose'"
}
	
* local pathwfile "//hume/rdc-gen/consolidated/soep-core/soep.v31_test/bepgen.dta"
* local pathwfile "//hume/rdc-gen/consolidated/soep-core/soep.v31_test/bdpgen.dta"
* local using "\\hume\rdc-gen\generations\soep-core\soep.v31_test\partial"
* local keyvars ""
getfilename2 `pathwfile'
local fileroot = r(root)
local filepath = r(path)
if "`verbose'"=="verbose" {
	display "fileroot from getfilename2:`fileroot'"
}
tempfile usefile
quietly use "`filepath'/`fileroot'", clear
quietly ds
local mastervars = r(varlist)
if "`verbose'"=="verbose" {
	display "variables in master:`mastervars'"
}
quietly save `usefile'

* use keyvars from soepidvars, if no keyvars specified
if `"`keyvars'"'=="" {
	soepidvars, verbose
	*local keyvars_bdpgen persnr
	*local keyvars_bepgen persnr
	*local keyvars = "`keyvars_`fileroot''"	
	soepidvars, verbose
	local keyvars = r(idvars)
}
if "`verbose'"=="verbose" {
	display "used keyvars: `keyvars'"
}

* generate tempfile allrows with all rows
keep `keyvars'
tempfile allrows
quietly save `allrows'
if "`verbose'"=="verbose" {
	display "describe dataset with all rows"
	desc
}

local mergefiles : dir "`using'" files "`fileroot'_*.dta"
if "`verbose'"=="verbose" {
	display `"Files to merge: `mergefiles'"'
}
local filescount : word count `mergefiles'
if "`verbose'"=="verbose" {
	display "Number of files to merge `filescount'"
}

* set trace off
foreach fileno of numlist 1/`filescount' {
	local file : word `fileno' of `mergefiles'
	if "`verbose'"=="verbose" {
		display "Processing file: `file':"
	}
	tempfile mergefile`fileno'
	quietly use "`using'/`file'", clear
	quietly save `mergefile`fileno'', replace
	quietly ds
	local varlist = r(varlist)
	if "`verbose'"=="verbose" {
		display "Variables in file: `varlist'"
	}
	local file`fileno'_newvars = "`varlist'"
	local varlist = r(varlist)
	if "`verbose'"=="verbose" {
		display "List of variables to be reduced: `file`fileno'_newvars'"
	}
	foreach var of local keyvars {
		* display "`var'"
		local file`fileno'_newvars : subinstr local file`fileno'_newvars "`var'" ""
	}
	if "`verbose'"=="verbose" {
		display "Variables to be added: `file`fileno'_newvars'"
	}
	
	local file`fileno'_status OK
	foreach keyvar of local keyvars {
		local type : type `keyvar'
		if "`type'"!="long" {
			local file`fileno'_status "NO, not all keyvars with type long"		
		}
	}
	
	capture merge 1:1 `keyvars' using `allrows', assert(match) nogen
	if _rc != 0 & "`file`fileno'_status'"=="OK" {
		local file`fileno'_status "NO, rows do not match"		
	}
			
	if "`file`fileno'_status'"=="OK" {
		foreach var of local file`fileno'_newvars {
			* display "usevars: `file`fileno'_usevars'"
			* display "var: `var'"
			capture confirm string variable `var'
            if !_rc {
				local foundvar ""
				foreach mvar of local mastervars {
					*display "mvar: ::`mvar'::"
					if "`mvar'"=="`var'" local foundvar = "`var'"
					*display "var: ::`var'::"
					*display "foundvar: ::`foundvar'::"
				}
				if "`foundvar'"!="" {					
					local file`fileno'_usevars = `"`file`fileno'_usevars' `var'"'
					if "`verbose'"=="verbose" {
						display "Variable `var' is string and is used without more validations."
					}
				}
				else {
					local file`fileno'_notusevars = `"`file`fileno'_notusevars' `var'"'
					local file`fileno'_status "some variable(s) NOT used: new string"
					if "`verbose'"=="verbose" {
						display "Variable `var' is string, new and NOT used."
					}
				}
            }
            else {
				* action for numeric variables 
				quietly count if `var'==.
				if `r(N)'==0 {
					* display "Variable `var' has no missings."
					local foundvar ""
					foreach mvar of local mastervars {
						if "`mvar'"=="`var'" local foundvar = "`var'"					
					}
					if "`foundvar'"!="" {					
						local file`fileno'_usevars = `"`file`fileno'_usevars' `var'"'
						if "`verbose'"=="verbose" {
							display "Variable `var' has no missings and is used."
						}
					}
					else {
						local file`fileno'_notusevars = `"`file`fileno'_notusevars' `var'"'
						local file`fileno'_status "some variable(s) NOT used: new or with missing"
					}
				}
				else {
					local file`fileno'_notusevars = `"`file`fileno'_notusevars' `var'"'
					local file`fileno'_status "some variable(s) NOT used: new or with missing"				
				}
			}
		}
	}
	if "`verbose'"=="verbose" {
		display "File No `fileno', Name `file' has status: `file`fileno'_status'."
		display "Use variables: `file`fileno'_usevars'."
		display "Do not use variables: `file`fileno'_notusevars'."
	}
}


* delete existing values (set to . or "") and merge
quietly use `usefile', clear
foreach fileno of numlist 1/`filescount' {
	local file : word `fileno' of `mergefiles'
	display "Related file: `file':"
	if "`file`fileno'_usevars'"=="" | "`file`fileno'_status'"!="OK" {
		display "Not merged."
		display
	}
	else {
		foreach var of varlist `file`fileno'_usevars' {
			capture confirm string variable `var'
            if !_rc {
				*action for string variables
				quietly replace `var'=""
            }
            else {
				*action for numeric variables 
				quietly replace `var'=.
				* display "Set `var' (in master) to . (missing)."
			}
		}
		display "Updated variable(s): `file`fileno'_usevars'."
		if "`file`fileno'_notusevars'"!="" {
			display "Not updated variable(s): `file`fileno'_notusevars'."
		}
		display
		*preserve
		*use `mergefile`fileno'', clear
		*desc
		*restore
		*desc
		quietly merge 1:1 `keyvars' using `mergefile`fileno'', ///
			keepusing(`file`fileno'_usevars') ///
			assert(match match_update) update nogen
	}
}
display "Merged by variable(s): `keyvars'"

end
