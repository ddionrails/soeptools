/*-------------------------------------------------------------------------------
  soepgenpre.ado: Open a template file and integrate variables from related files

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
*! soepgenpre.ado: Consolidate files from three sources (consolidated, partial, complete)
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.3.5 4 July 2018 - update for version 14 and above
*! version 0.15 29 September 2016 - soepgenpre/soepusemerge: report in partialresult.xls
*! version 0.7 17 June 2016 - soepgenpre: underscore in filenames #6
*! version 0.6.1 30 May 2016 - soepgenpre: add quiety prior rsync
*! version 0.5 12 May 2016 - soepgenpre: introduce options dopartial and docomplete
*! version 0.5 12 May 2016 - soepgenpre: introduce options dopartial and docomplete
*! version 0.2 18 April 2016 - introduce soepgenpre

program define soepgenpre, nclass
	version 14 
	syntax , version(string) [humepath(string) verbose empty replace dopartial docomplete rsync]
if "`verbose'"=="verbose" {
	display `"version:`version':"'
	display `"humepathpre:`humepath':"'
}
if "`humepath'"=="" {
	if "`c(os)'`c(username)'"=="Unixjgoebel" {
		local humepath "/mnt/"
	}
	if "`c(os)'"=="Windows" {
		local humepath "//hume/"
	}
}
local consolidated = "`humepath'rdc-gen/consolidated/soep-core/soep.`version'/"
local partial = "`humepath'rdc-gen/generations/soep-core/soep.`version'/partial/"
local complete = "`humepath'rdc-gen/generations/soep-core/soep.`version'/complete/"
local pre "`humepath'rdc-gen/generations/soep-core/soep.`version'/pre/"
if "`verbose'"=="verbose" {
	display `"humepathpost:`humepath':"'
	display `"consolidated:+`consolidated'+"'
	display `"partial:+`partial'+"'
	display `"complete:+`complete'+"'
	display `"pre:+`pre'+"'
	display `"dopartial:+`dopartial'+"'
}

* empty: delete files in pre folder
if "`empty'"=="empty" {
	local prefiles : dir "`pre'" files "*"
	if "`verbose'"=="verbose" {
		display `"files to delete in pre folder: `prefiles'"'
	}
	foreach prefile of local prefiles {
		local delete = "`pre'`prefile'"
		erase "`delete'"
	}
}


* START: local partials: all partials_blabla.dta, with updates

local partialnames : dir "`partial'" files "*_*.dta"
if "`verbose'"=="verbose" {
	display `"files in partial: `partialnames'"'
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
	display "unique file roots in partial:`partials'"
}
* END: local partials: all partials_blabla.dta, with updates

* local consolidateds: alle files in consolidated
local consolidateds : dir "`consolidated'" files "*.dta"
local consolidateds : subinstr local consolidateds ".dta" "", all
local consolidateds : subinstr local consolidateds `"""' "", all
if "`verbose'"=="verbose" {
	display `"files in consolidated: `consolidateds'"'
}

* local complete: alle files in complete
local completes : dir "`complete'" files "*.dta"
local completes : subinstr local completes ".dta" "", all
local completes : subinstr local completes `"""' "", all
if "`verbose'"=="verbose" {
	display `"files in complete: `completes'"'
}

local allfiles = `"`completes' `partials' `consolidateds'"'
* display `"`allfiles'"'
	
local number : word count `allfiles'
* display "number: `number'"

* init tempfile partialresults
clear
tempfile partialresults
gen consolidated=""
gen keyvars=""
gen partial=""
gen partialstatus=""
gen partialused=""
gen partialnotused=""
save `partialresults', replace emptyok

while `number' > 0 {
	local file : word 1 of `allfiles'
	local filestatus "consolidated"
	foreach check of local partials {
		if "`check'" == "`file'" local filestatus "partial"
	}
	foreach check of local completes {
		if "`check'" == "`file'" local filestatus "complete"
	}
	if "`filestatus'" == "complete" & "`dopartial'"=="" {
		if "`verbose'"=="verbose" {
			display "`file' is complete: copy from complete"
		}
		if "`rsync'"=="rsync" {
			qui shell  rsync -a "`complete'`file'.dta" "`pre'`file'.dta"
		}
		else {
			copy "`complete'`file'.dta" "`pre'`file'.dta", `replace'
		}
	}
	if "`filestatus'" == "partial" & "`docomplete'"=="" {
		if "`verbose'"=="verbose" {
			display "`file' is partial: merge with related files"			
		}
		* display "use:`consolidated'`file'.dta:"
		* display "using:`partial':"
		quietly: soepusemerge "`consolidated'`file'.dta" using "`partial'", clear `verbose'
		saveascii "`pre'`file'", `replace' version(12)
		use `partialresults', clear
		keep if consolidated==""
		if `e(usingfilesno)'>0 {
			set obs `e(usingfilesno)'
			replace keyvars="`e(masterkeyvars)'"
			replace consolidated="`e(masterfile)'"
		}

		forvalues no = 1/`e(usingfilesno)' {
			local partialfile: word `no' of "`e(usingfiles)'"
			replace partial       ="`partialfile'"               in `no'
			replace partialstatus ="`e(file`no'status)'"     in `no'
			capture replace partialused   ="`e(file`no'usevars)'"    in `no'
			capture replace partialnotused="`e(file`no'notusevars)'" in `no'
		}

		append using `partialresults'
		save `partialresults', replace emptyok
		
	}
	if "`filestatus'" == "consolidated" & "`docomplete'"=="" & "`dopartial'"=="" {
		if "`verbose'"=="verbose" {
			display "`file' is only in consolidated: copy from consolidated"
		}
		if "`rsync'"=="rsync" {
			qui shell rsync -a "`consolidated'`file'.dta" "`pre'`file'.dta"
		}
		else {
			copy "`consolidated'`file'.dta" "`pre'`file'.dta", `replace'
		}			
	}
	local allfiles : subinstr local allfiles "`file'" "", all word
	local number : word count `allfiles'
}
use `partialresults'
quietly if _N==0 set obs 1
export excel using "`pre'/partialresults.xls", firstrow(variables) replace

end
