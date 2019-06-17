/*-------------------------------------------------------------------------------
  soepusemerge.ado: Open a template file and integrate variables from related files

    Copyright (C) 2016-2017  Knut Wenzig (kwenzig@diw.de)

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
*! version 0.4 June 17, 2019 - introduce soepinitdta und soepcompletemd, updates for v35
*! version 0.3.6 9 July 2018 - soepnextcons: bugfix in warning; soepusemerge takes care of _ in suffixes
*! version 0.3.5 4 July 2018 - update for version 14 and above
*! version 0.2.3 16 Juni 2017 - soepusemerge: fix exception handling for non-fitting partials
*! version 0.2.2 15 Juni 2017 - soepnextcons/soepusemerge: check for dtaversion
*! version 0.2 31 Maerz 2017 - recstructed log in partialresult.xls
*! version 0.15 29 September 2016 - soepgenpre/soepusemerge: report in partialresult.xls
*! version 0.13 28 September 2016 - soepusemerge: bugfix
*! version 0.12 28 September 2016 - soepusemerge: fix for keys not in partial
*! version 0.11 27 September 2016 - require keyvars of type long
*! version 0.1 13 April 2016 - initial release

program define soepusemerge , eclass
	version 14
	syntax anything(name=pathwfile) using/ , clear [keyvars(namelist) verbose compare]

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
ereturn local masterfile `fileroot'
tempfile usefile
quietly useold "`filepath'/`fileroot'", clear
quietly ds
local mastervars = r(varlist)
if "`verbose'"=="verbose" {
	display "variables in master: `mastervars'"
}
quietly save `usefile'

* use keyvars from soepidvars, if no keyvars specified
if `"`keyvars'"'=="" {
	soepidvars, `verbose'
	*local keyvars_bdpgen persnr
	*local keyvars_bepgen persnr
	*local keyvars = "`keyvars_`fileroot''"	
	local keyvars = r(idvars)
}
if "`verbose'"=="verbose" {
	display "used keyvars: `keyvars'"
}
ereturn local masterkeyvars `keyvars'
* generate tempfile allrows with all rows
keep `keyvars'
tempfile allrows
quietly save `allrows'
if "`verbose'"=="verbose" {
	display "describe dataset with all rows"
	desc
}

local mergefilesraw : dir "`using'" files "`fileroot'_*.dta", respectcase
if "`verbose'"=="verbose" {
	display `"Files to merge: `mergefilesraw'"'
}

* mergefiles ausschließen, die im Suffix einen weiteren Unterstrich haben
local filescount : word count `mergefilesraw'
if "`verbose'"=="verbose" {
	display "Number of files to merge `filescount'"
}
local suffixes : subinstr local mergefilesraw "`fileroot'_" "", all
if "`verbose'"=="verbose" {
	display `"`suffixes'"'
}
local suffixescheck : subinstr local suffixes "_" "", all
if "`verbose'"=="verbose" {
	display `"`suffixescheck'"'
}

local mergefiles
local dropfiles

foreach fileno of numlist 1/`filescount' {
	local mergefile: word `fileno' of `mergefilesraw'
	local suffix: word `fileno' of `suffixes'
	local suffixcheck: word `fileno' of `suffixescheck'
	display "Test: `mergefile'"
	if "`suffix'"=="`suffixcheck'" {
		local mergefiles = "`mergefile' "+"`mergefiles'"
		if "`verbose'"=="verbose" {
			display "Wird aufgenommen."
			display "aktuelle mergefiles: `mergefiles'"
		}
	}
	else {
		local dropfiles = "`mergefile' "+"`dropfiles'"
		if "`verbose'"=="verbose" {
			display "Wird nicht aufgenommen."
			display "aktuelle dropfiles: `dropfiles'"
		}
	}
}
* Das sind nur mergefiles ohne _ im Sufix
if "`verbose'"=="verbose" {
	display "finale mergefiles: `mergefiles'"
}

ereturn local usingfiles `mergefiles'
local filescount : word count `mergefiles'
if "`verbose'"=="verbose" {
	display "Number of files to merge `filescount'"
}
ereturn local usingfilesno `filescount'
* set trace off
foreach fileno of numlist 1/`filescount' {
	local file : word `fileno' of `mergefiles'
	if "`verbose'"=="verbose" {
		display "Processing file: `file':"
	}
	
	dtaversion "`using'/`file'"
	local dversion = r(version)
	display "Version: `dversion'"
	
	local file`fileno'_status "OK"
	local file`fileno'_message
	
	if `dversion' > 117 {
		local file`fileno'_status "ERROR"
		local file`fileno'_message "`file`fileno'_message'File is dta_`dversion', not Stata 12 (115). "
		if "`verbose'"=="verbose" {
			display "ERROR: File is dta_`dversion', more recent than Stata 13 (117)."
		}
	}
	else if `dversion' != 115 {
		local file`fileno'_status "Warning"
		local file`fileno'_message "`file`fileno'_message'File is dta_`dversion', not Stata 12 (115). "
		if "`verbose'"=="verbose" {
			display "Warning: File is dta_`dversion', e.g. Stata 13 (117) or older than Stata 12 (115)"
		}
	}
	if "`file`fileno'_status'"!="ERROR" {
		tempfile mergefile`fileno'
		quietly useold "`using'/`file'", clear
		quietly save `mergefile`fileno'', replace
		quietly ds
		local varlist = r(varlist)
		if "`verbose'"=="verbose" {
			display "Variables in file: `varlist'"
		}
		local file`fileno'_newvars : list varlist - keyvars
		if "`verbose'"=="verbose" {
			display "Variables to be checked for adding: `file`fileno'_newvars'"
		}
	
		local file`fileno'_navarlist
		local file`fileno'_keyvars : list varlist & keyvars
		if "`verbose'"=="verbose" {
			display "Found keyvars: `file`fileno'_keyvars'"
		}
	
		local file`fileno'_keyvars_check : list file`fileno'_keyvars === keyvars
	
		if "`file`fileno'_keyvars_check'"=="0" {
			local file`fileno'_status "ERROR"
			local file`fileno'_message "`file`fileno'_message'Keyvar(s) missing. "
			local file`fileno'_withoutkey : list keyvars - file`fileno'_keyvars
		}
		else {
			if "`verbose'"=="verbose" {
				display "All keyvars found."
			}
		}
		local typecheck
		foreach keyvar of local file`fileno'_keyvars {
			local type : type `keyvar'
			local typecheck "`typecheck' `type'"
		}
		local typecheck : list uniq typecheck
		if "`typecheck'"!="long" {
				local file`fileno'_status "ERROR"
				local file`fileno'_message "`file`fileno'_message'Keyvar(s) not long. "
		}
	
		capture merge 1:1 `keyvars' using `allrows', assert(match) nogen
		if _rc != 0 & "`file`fileno'_status'"!="ERROR" {
			local file`fileno'_status "ERROR"
			local file`fileno'_message "`file`fileno'_message'Rows do not match. "		
		}
	}	
	if "`file`fileno'_status'"!="ERROR" {
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
					local file`fileno'_status "Warning"
					local file`fileno'_message "`file`fileno'_message'Some variable(s) NOT used: new string. "
					if "`verbose'"=="verbose" {
						display "Variable `var' is string, new and NOT used."
					}
				}
            }
            else {
				* action for numeric variables 
				local found : list var in mastervars
				if `found'==1 {
					quietly count if `var'==.
					if `r(N)'==0 {
						* display "Variable `var' has no missings."
						local file`fileno'_usevars = `"`file`fileno'_usevars' `var'"'
						if "`verbose'"=="verbose" {
							display "Variable `var' has no missings and is used."
						}
					}
					else {
						local file`fileno'_usevars = `"`file`fileno'_usevars' `var'"'
						local file`fileno'_navarlist = `"`file`fileno'_navarlist' `var'"'
						local file`fileno'_status "Warning"
						local file`fileno'_message "`file`fileno'_message'Variable(s) containing NAs. "
					}
				}
				else {
					local file`fileno'_notusevars = `"`file`fileno'_notusevars' `var'"'
					local file`fileno'_status "Warning"
					local file`fileno'_message "`file`fileno'_message'Superflous variable(s) dropped. "
				}
			}
		}
	}
	if "`verbose'"=="verbose" {
		display "File No `fileno', Name `file' has status: `file`fileno'_status'."
		display "Info: `file`fileno'_message'"
		display "Use variables: `file`fileno'_usevars'."
		display "Variables with NA (used): `file`fileno'_navarlist'."
		display "Do not use variables: `file`fileno'_notusevars'."
	}
}


* delete existing values (set to . or "") and merge
quietly use `usefile', clear
foreach fileno of numlist 1/`filescount' {
	local file : word `fileno' of `mergefiles'
	display "Related file: `file':"
	if "`file`fileno'_usevars'"=="" | "`file`fileno'_status'"=="ERROR" {
		display "Not merged."		
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
		* display
		*preserve
		*use `mergefile`fileno'', clear
		*desc
		*restore
		*desc
		quietly merge 1:1 `keyvars' using `mergefile`fileno'', ///
			keepusing(`file`fileno'_usevars') ///
			assert(match match_update) update nogen
		/*
		if "`compare'"=="compare" {
			preserve
			soepcomparelabel "`filepath'/`fileroot'" using "`using'/`file'" , clear
			ereturn local file`fileno'varlab "`e(varlab)'"
			ereturn local file`fileno'vallab "`e(vallab)'"
			restore
		}
		*/
	}
	ereturn local file`fileno'status `file`fileno'_status'
	ereturn local file`fileno'message `file`fileno'_message'
	ereturn local file`fileno'usevars `file`fileno'_usevars'
	ereturn local file`fileno'navars `file`fileno'_navarlist'
	ereturn local file`fileno'notusevars `file`fileno'_notusevars'

}
display "Merged by variable(s): `keyvars'"

end
