/*-------------------------------------------------------------------------------
  soepallcons.ado: produce all consolidated from all partial and complete folders

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
*! soepallcons.ado: produce all consolidated from all partial and complete folders
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.4 June 17, 2019 - introduce soepinitdta und soepcompletemd, updates for v35
*! version 0.3 26 Juni 2017 - introduce soepdatetime and write excel files with timestamp
*! version 0.2.1 24 Mai 2017 - soepallcons: bugfix for emptyexcel exports
*! version 0.2 31 Maerz 2017 - introduce soepallcons

program define soepallcons, nclass
	version 13 
	syntax , version(string) [humepath(string) verbose empty replace arch rsync]

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

if "`arch'"== "" {
	local genroot =  "`humepath'rdc-gen/generations/soep-core/soep.`version'/"
	local consroot = "`humepath'rdc-gen/consolidated/soep-core/soep.`version'/"
}
if "`arch'"== "arch" {
	local genroot =  "`humepath'rdc-arch/consolidate/soep-core/`version'/"
	local consroot = "`humepath'rdc-arch/consolidate/soep-core/`version'/"
}

local types "partial complete consolidated"
foreach type of local types {
	local root = "`genroot'"
	if "`type'"=="consolidated" local root = "`consroot'"
	local suffixes : dir "`root'" dirs "`type'*", respectcase
	local suffixes : list clean suffixes
	local suffixes : subinstr local suffixes "`type'" "", all count(local dirsno)
	forvalues n = 1/`dirsno' {
		local suffix : word `n' of `suffixes'
		capture assert `n'==`suffix'
		if _rc!=0 {
			display as error "`type' folders not enumerated correctly in increasing order."
			exit 9			
		}
	}
	local `type'max = `dirsno'
	if "`verbose'"=="verbose" {
		display "``type'max' highest suffix for `type' folders."
	}
}
	
local steps = `partialmax'
if `partialmax'>`completemax' local steps = `completemax'
if "`verbose'"=="verbose" {
	display "`steps' step(s) to be processed."
}
capture assert `steps'<`consolidatedmax'
if _rc!=0 {
	display as error "Not enough consolidated folders."
	exit 9			
}

soepdatetime, `verbose'
local timestamp `"_`r(datetime)'"'

forvalues step = 1/`steps' {
	if "`verbose'"=="verbose" {
		display "Processing step `step'."
	}
	soepnextcons, version(`version') step(`step') `empty' `replace' `rsync' `verbose' `arch' timestamp(`timestamp')
	local types "partial complete"
	foreach type of local types {
		tempfile `type'sheet`step'
		import excel "`genroot'`type'`step'/`type'results`timestamp'.xls", sheet("Sheet1") firstrow allstring clear
		quietly save ``type'sheet`step'', replace
	}	
}

local types "partial complete"
foreach type of local types {
	clear
	forvalues step = 1/`steps' {
		append using ``type'sheet`step''
		quietly drop if step==""
		local stepplus1 = `step'+1
		quietly if _N==0 set obs 1
		quietly export excel using "`consroot'consolidated`stepplus1'/`type'results`timestamp'.xls", firstrow(variables) replace
	}
}

end
