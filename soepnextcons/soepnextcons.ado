/*-------------------------------------------------------------------------------
  soepnextcons.ado: consolidate complete+partial+consolidated for next consolidated

    Copyright (C) 2017  Knut Wenzig (kwenzig@diw.de)

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
*! soepnextcons.ado: consolidate complete+partial+consolidated for next consolidated
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.3.5 4 July 2018 - update for version 14 and above
*! version 0.3.2 4 July 2017 - soepidsvars: return nothing, if no keyvar is found
*!                             soepnextcons: use keyvars from complete file
*! version 0.3.1 29 Juni 2017 - soepnextcons: empty deletes only dta files, ERROR-files in complete copied from consolidated
*! version 0.3 26 Juni 2017 - introduce soepdatetime and write excel files with timestamp
*! version 0.2.2 15 Juni 2017 - soepnextcons/soepusemerge: check for dtaversion
*! version 0.2 31 Maerz 2017 - introduce soepnextcons

program define soepnextcons, nclass
	version 14 
	syntax , version(string) step(integer) [humepath(string) verbose empty replace rsync timestamp(string)]

* check whether saveascii is installed
quietly capture findfile saveascii.ado
if "`r(fn)'" == "" {
         di as txt "package saveascii needs to be installed first;"
         di as txt "use -ssc install saveascii- to do that"
         exit 498
}	
	
	
/*
if "`verbose'"=="verbose" {
	display `"version:`version':"'
	display `"humepathpre:`humepath':"'
}
*/
if "`verbose'"=="verbose" {
	display "timestamp: `timestamp'"	
}

if "`humepath'"=="" {
	if "`c(os)'`c(username)'"=="Unixjgoebel" {
		local humepath "/mnt/"
	}
	if "`c(os)'"=="Windows" {
		local humepath "//hume/"
	}
}

local stepplus1 = `step'+1

local consolidated = "`humepath'rdc-gen/consolidated/soep-core/soep.`version'/consolidated`step'/"
local partial = "`humepath'rdc-gen/generations/soep-core/soep.`version'/partial`step'/"
local complete = "`humepath'rdc-gen/generations/soep-core/soep.`version'/complete`step'/"
local nextconsolidated = "`humepath'rdc-gen/consolidated/soep-core/soep.`version'/consolidated`stepplus1'/"
/*
if "`verbose'"=="verbose" {
	display `"humepathpost: +`humepath'+"'
	display `"step: +`step'+"'
	display `"consolidated: +`consolidated'+"'
	display `"partial: +`partial'+"'
	display `"complete: +`complete'+"'
	display `"step + 1:+`stepplus1'+"'	
}
*/
* option empty: delete dta-files in nextconsolidated folder
if "`empty'"=="empty" {
	local nextconsolidatedfiles : dir "`nextconsolidated'" files "*.dta"
	if "`verbose'"=="verbose" {
		display `"Files to delete in consolidated`stepplus1' folder: `nextconsolidatedfiles'"'
	}
	foreach nextconsolidatedfile of local nextconsolidatedfiles {
		local delete = "`nextconsolidated'`nextconsolidatedfile'"
		erase "`delete'"
	}
}


* START: local partials: all partials_blabla.dta, with updates

local partialnames : dir "`partial'" files "*_*.dta"
if "`verbose'"=="verbose" {
	display `"Files in partial`step': `partialnames'"'
}
* all root file names (parts before last underscore) in partial folder
foreach file of local partialnames {
	local addroot = ""
	local left = ""
	while "`file'" != "" {
		local addroot = "`addroot'`left'"
		gettoken left file : file, parse("_") quotes
		* display "left: `left'"
		gettoken nextleft rest : file, parse("_") quotes
		if "`rest'"=="" local file = ""
		* display "nextleft: `nextleft'"
		* display "rest: `rest'"
		* display "addroot: `addroot'"
		* display "file: |`file'|"
	}
	local root = "`root' `addroot'"
	* display "root: `root'"
}

/*
if "`verbose'"=="verbose" {
	display "root files in partial: `root'"
}
*local test : subinstr local root "`firstroot`" "", all word
*/

local number : word count `root'
* display "number: `number'"

* make root file names found in partial folder unique
while `number' > 0 {
	local firstroot : word 1 of `root'
	* display "firstroot:`firstroot'"
	local partials = `"`partials' `firstroot'"'
	* display "partial:`partials'"
	local root : subinstr local root "`firstroot'" "", all word
	* display "root:`root':"
	local number : word count `root'
	* display "number: `number'"
}
if "`verbose'"=="verbose" {
	display "Unique file roots in partial`step':`partials'"
}
* END: local partials: all partials_blabla.dta, with updates

* local consolidateds: alle files in consolidated
local consolidateds : dir "`consolidated'" files "*.dta"
local consolidateds : subinstr local consolidateds ".dta" "", all
local consolidateds : subinstr local consolidateds `"""' "", all
if "`verbose'"=="verbose" {
	display `"Files in consolidated`step': `consolidateds'"'
}

* local complete: alle files in complete
local completes : dir "`complete'" files "*.dta"
local completes : subinstr local completes ".dta" "", all
local completes : subinstr local completes `"""' "", all
if "`verbose'"=="verbose" {
	display `"Files in complete`step': `completes'"'
}

/*
* alle files, die in consolidated ersetzt/ergänzt werden
local tempfiles "`completes' `partials'"
local number : word count `tempfiles'
set trace off
while `number' > 0 {
	local firstfile : word 1 of `tempfiles'
	local tempfiles2 : subinstr local consolidateds "`firstfile'" "", all word count(local n2)
	if "`n2'"!="0" local consused = `"`consused' `firstfile'"'
	local tempfiles : subinstr local tempfiles "`firstfile'" "", all word
	local number : word count `tempfiles'
}
display "files in consolidated to update: `consused'"
set trace off

foreach file of local consused {
	display "`file'"
	use `consolidated'`file', clear
    preserve
	uselabel, clear
	rename lname vallab
	tempfile meta`file'
	save `meta`file'', replace
	restore
	describe, replace
	joinby vallab using `meta`file'', unmatched(master)
	rename name variable
	keep variable isnumeric varlab value label
	save `meta`file'', replace
	display "metasaved: meta`file'"
} 
*/

local allfiles = `"`completes' `partials' `consolidateds'"'
* display `"`allfiles'"'
	
local number : word count `allfiles'
* display "number: `number'"


* init tempfile completeresults
clear
tempfile completeresults
gen step=""
gen folder=""
gen file=""
gen status=""
gen message=""
gen master =""
gen keyvars=""
gen withoutkey=""
gen isid_keyvars =""
gen notused=""
gen withNA=""
gen missing=""
gen varlab=""
gen vallab=""

quietly save `completeresults', replace emptyok




* 1. alle completes mit consolidate vergleichen und in nextconsolidated schreiben

local consolidatedremain "`consolidateds'"
foreach file of local completes {
	local status "OK"
	local message
	local keyvars
	local isid_keyvars
	local withoutkey
	local notused
	local missing
	local navarlist
	local varlab
	local vallab	
	
	* is file in consolidated?
	* display "`conolidates'"
	local consolidatedremain : subinstr local consolidatedremain `"`file'"' "", all word count(local found)
	* display "file: `file', consolidateds: `consolidatedremain', found: `found'"
	* detect version of file
	dtaversion "`complete'`file'.dta"
	local dversion r(version)
	if "`found'"=="0" {
		* NO: file in not consolidated
		local status "ERROR"
		local message "`message' NOT found in consolidated`step'. "
	}
	else if `dversion' > 117 {
		local status "ERROR"
		local message "`message'File is dta_`dversion', not Stata 12 (115). "
		* instead copy file form consolidated
		local consolidatedremain `consolidatedremain' `file'
	}
	else {
		if `dversion'==117 | `dversion'<115{
			local status "Warning"
			local message "`message'File is dta_`dversion', not Stata 12 (115). "
		}
		* empty consolidated file and write to tempfile consolidatedfile
		* - will become master for append
		quietly useold `consolidated'`file', clear
		quietly ds
		local consvarlist = r(varlist)
		tempvar drophelp
		gen `drophelp'=1
		quietly drop if `drophelp'==1
		quietly drop `drophelp'
		quietly describe
		local cases = `r(N)'
		* display "cases: `cases'"
		tempfile consolidatedfile
		quietly save `consolidatedfile', replace
		
		quietly useold `complete'`file', clear
		quietly ds
		local compvarlist = r(varlist)
		local keepvarlist "`compvarlist'"
		quietly soepidvars, `verbose'
		local keyvars = r(idvars)
		display "keyvars: `keyvars'"
		local navarlist 
		local missing "`consvarlist'"
		* local withoutkey "`keyvars'"
		local notused 
		foreach variable of local compvarlist {
			local missing : subinstr local missing `"`variable'"' "", all word count(local found)
			if "`found'"=="0"{
				local notused "`notused' `variable'"
				local status "Warning"
				local message "`message'Superflous variable(s) dropped. "
				quietly drop `variable'				
			}
			else {
				capture confirm string variable `variable'
				if _rc {
					quietly count if `variable' == .
					if `r(N)'>0 {
						local navarlist "`navarlist' `variable'"
						local status "Warning"
						local message "`message'Variable(s) containg NAs. "
					}
				}
			}
			* local withoutkey : subinstr local withoutkey `"`variable'"' "", all word
			
		}
		capture isid `keyvars'
		* display "capture isid `keyvars'"
		if _rc==0 {		
			tempfile toappend
			* desc
			quietly save `toappend', replace
			quietly use `consolidatedfile', clear
			* desc
			quietly append using `toappend'
			* desc
			quietly saveascii `nextconsolidated'`file', replace version(12)
		}
		else {
			local status "ERROR"
			local message "`message'No keyvar(s) found. "
			local isid_keyvars "NO"
			* instead copy file form consolidated
			local consolidatedremain `consolidatedremain' `file'
		}
		if "`status'"!="ERROR" {
			soepcomparelabel `consolidated'`file' using `complete'`file', clear
			local varlab "`e(varlab)'"
			local vallab "`e(vallab)'"
		}
	}
		
	* display "consolidated remain: `consolidatedremain'"
	
	quietly use `completeresults', clear
	quietly describe
	local filesno = `r(N)' + 1
	quietly set obs `filesno'
	quietly replace step="`step'" in `filesno'
	quietly replace folder="complete" in `filesno'
	quietly replace file="`file'" in `filesno'
	quietly replace status="`status'" in `filesno'
	quietly replace message=trim("`message'") in `filesno'
	quietly replace master="`file'" in `filesno'
	quietly replace keyvars="`keyvars'" in `filesno'
	quietly replace withoutkey=trim("`withoutkey'") in `filesno'
	quietly replace isid_keyvars = "`isid_keyvars'" in `filesno'
	quietly replace notused=trim("`notused'") in `filesno'
	quietly replace withNA=trim("`navarlist'") in `filesno'
	quietly replace missing=trim("`missing'") in `filesno'
	quietly replace varlab=trim("`varlab'") in `filesno'
	quietly replace vallab=trim("`vallab'") in `filesno'
	quietly replace missing=trim("`missing'") in `filesno'
	quietly save `completeresults', replace
		
}

* 2. alle consolidate, die nicht in complete sind in nextconsolidated schreiben

display "consolidated remain: `consolidatedremain'"

foreach file of local consolidatedremain {
	if "`rsync'"=="rsync" {
		qui shell rsync -a "`consolidated'`file'.dta" "`nextconsolidated'`file'.dta"
	}
	else {
			quietly copy "`consolidated'`file'.dta" "`nextconsolidated'`file'.dta", `replace'
	}
}

* 3. alle files, für die es partial gibt, mit den partials verbinden

* local nextconsolidateds: alle files in nextconsolidated
local nextconsolidateds : dir "`nextconsolidated'" files "*.dta"
local nextconsolidateds : subinstr local nextconsolidateds ".dta" "", all
local nextconsolidateds : subinstr local nextconsolidateds `"""' "", all
if "`verbose'"=="verbose" {
	display `"New files in consolidated`stepplus1': `nextconsolidateds'"'
}

* init tempfile partialresults
clear
tempfile partialresults
quietly gen step=""
quietly gen folder=""
quietly gen file=""
quietly gen status=""
quietly gen message=""
quietly gen master=""
quietly gen keyvars=""
quietly gen partialused=""
quietly gen withNA=""
quietly gen notused=""
quietly gen varlab=""
quietly gen vallab=""
quietly save `partialresults', replace emptyok

foreach file of local partials {
	local tempfiles : subinstr local nextconsolidateds `"`file'"' "", all word count(local hasconsolidated)
		if "`hasconsolidated'"=="0"{
			continue
		}
		soepusemerge "`nextconsolidated'`file'.dta" using "`partial'", clear
		quietly saveascii "`nextconsolidated'`file'", replace version(12)
		quietly use `partialresults', clear
		quietly keep if master==""
		if `e(usingfilesno)'>0 {
			quietly set obs `e(usingfilesno)'
			quietly replace keyvars="`e(masterkeyvars)'"
			quietly replace master="`e(masterfile)'"
		}

		forvalues no = 1/`e(usingfilesno)' {
			local partialfile: word `no' of "`e(usingfiles)'"
			quietly replace step = "`step'" in `no' 
			quietly replace folder = "partial" in `no' 
			quietly replace file       ="`partialfile'"               in `no'
			quietly replace status ="`e(file`no'status)'"     in `no'
			quietly replace message =trim("`e(file`no'message)'")     in `no'
			quietly capture replace partialused   ="`e(file`no'usevars)'"    in `no'
			quietly capture replace withNA   ="`e(file`no'navars)'"    in `no'
			quietly capture replace notused="`e(file`no'notusevars)'" in `no'
			
			if "`e(file`no'status)'"!="ERROR" {
				preserve
				soepcomparelabel "`nextconsolidated'/`e(masterfile)'" using "`partial'/`partialfile'" , clear
				restore
					
				quietly capture replace varlab="`e(varlab)'" in `no'
				quietly capture replace vallab="`e(vallab)'" in `no'
			}
		}

		quietly append using `partialresults'
		quietly save `partialresults', replace emptyok
	

}

quietly use `partialresults', clear
quietly if _N==0 set obs 1
quietly export excel using "`partial'/partialresults`timestamp'.xls", firstrow(variables) replace

quietly use `completeresults', clear
quietly if _N==0 set obs 1
quietly export excel using "`complete'/completeresults`timestamp'.xls", firstrow(variables) replace

end
