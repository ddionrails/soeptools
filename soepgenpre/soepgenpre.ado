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
*! version 0.2 18 April 2016 - initial release

program define soepgenpre, nclass
	version 13 
	syntax , version(string) [humepath(string) verbose empty replace]
	* syntax , version(string) [humepath(asis)]
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


* local partials: alle partials_blabla.dta, für die es ein update gibt

local partialnames : dir "`partial'" files "*_*.dta"
if "`verbose'"=="verbose" {
	display `"files in partial: `partialnames'"'
}
foreach file of local partialnames {
	* display `"`partial'"'
	gettoken addroot rest : file, parse("_") quotes
    * display "`addroot'"
	local root = "`root' `addroot'"
}
/*
if "`verbose'"=="verbose" {
	display "root files in partial: `root'"
}
*local test : subinstr local root "`firstroot`" "", all word
*/

local number : word count `root'
* display "number: `number'"

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

* local consolidateds: alle files in consolidated
local consolidateds : dir "`consolidated'" files "*.dta"
local consolidateds : subinstr local consolidateds ".dta" "", all
local consolidateds : subinstr local consolidateds `"""' "", all
if "`verbose'"=="verbose" {
	display `"files in colsolidated: `consolidateds'"'
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

while `number' > 0 {
	local file : word 1 of `allfiles'
	local filestatus "consolidated"
	foreach check of local partials {
		if "`check'" == "`file'" local filestatus "partial"
	}
	foreach check of local completes {
		if "`check'" == "`file'" local filestatus "complete"
	}
	if "`filestatus'" == "complete" {
		if "`verbose'"=="verbose" {
			display "`file' is complete: copy from complete"
		}
		copy "`complete'`file'.dta" "`pre'`file'.dta", `replace'
	}
	if "`filestatus'" == "partial" {
		if "`verbose'"=="verbose" {
			display "`file' is partial: merge with related files"			
		}
		* display "use:`consolidated'`file'.dta:"
		* display "using:`partial':"
		quietly: soepusemerge "`consolidated'`file'.dta" using "`partial'", clear `verbose'
		saveold "`pre'`file'", `replace'
	}
	if "`filestatus'" == "consolidated" {
		if "`verbose'"=="verbose" {
			display "`file' is only in consolidated: copy from consolidated"
		}
		copy "`consolidated'`file'.dta" "`pre'`file'.dta", `replace'
	}
	local allfiles : subinstr local allfiles "`file'" "", all word
	local number : word count `allfiles'
}


end

/*


* local partials: alle partials_blabla.dta, für die es ein update gibt

local partialnames : dir "`partial'" files "*_*.dta"
display `"`partials'"'
foreach partial of local partialnames {
	display `"`partial'"'
	gettoken addroot rest : partial, parse("_") quotes
    display "`addroot'"
	local root = "`root' `addroot'"
	}
display "root: `root'"
*local test : subinstr local root "`firstroot`" "", all word

local number : word count `root'
display "number: `number'"

while `number' > 0 {
	local firstroot : word 1 of `root'
	display "firstroot:`firstroot'"
	local partials = `"`partials' `firstroot'"'
	display "partial:`partials'"
	local root : subinstr local root "`firstroot'" "", all word
	display "root:`root':"
	local number : word count `root'
	display "number: `number'"
}
display "partials:`partials'"

* local consolidateds: alle files in consolidated
local consolidateds : dir "`consolidated'" files "*.dta"
local consolidateds : subinstr local consolidateds ".dta" "", all
local consolidateds : subinstr local consolidateds `"""' "", all
display `"`consolidateds'"'

* local complete: alle files in complete
local completes : dir "`complete'" files "*.dta"
local completes : subinstr local completes ".dta" "", all
local completes : subinstr local completes `"""' "", all
display `"`completes'"'

local allfiles = `"`completes' `partials' `consolidateds'"'
display `"`allfiles'"'
	
local number : word count `allfiles'
display "number: `number'"

while `number' > 0 {
	local file : word 1 of `allfiles'
	local filestatus "consolidated"
	foreach check of local partials {
		if "`check'" == "`file'" local filestatus "partial"
	}
	foreach check of local completes {
		if "`check'" == "`file'" local filestatus "complete"
	}
	if "`filestatus'" == "complete" {
		display "`file' is complete: copy from complete"
	}
	if "`filestatus'" == "partial" {
		display "`file' is partial: merge with related files"
	}
	if "`filestatus'" == "consolidated" {
		display "`file' is only in consolidated: copy from consolidated"
	}
	local allfiles : subinstr local allfiles "`file'" "", all word
	local number : word count `allfiles'
}

*/
