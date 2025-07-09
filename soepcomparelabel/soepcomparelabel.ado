/*-------------------------------------------------------------------------------
  soepcomparelabel.ado: Compares Labels of Two Files

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
*! soepcomparelabel.ado: Compares Labels of Two Files
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany

*! version 0.5.13 July, 9, 2025 - nextcons/comparelabel/usemerge: use .dta filename extension, comparelabel: verbose
*! version 0.5.8 August 11, 2022 - soepcomparelabel: cut too long reporting for value labels
*! version 0.5.3 August 17, 2020 - soepcomparelabel: detects now missing value labels
*! version 0.2 31 Maerz 2017 - initial release

program define soepcomparelabel , eclass
	version 13
	syntax anything(name=pathwfile) using/ , clear verbose



* local using "//hume/rdc-gen/generations/soep-core/soep.v33_test/partial1/wmuki2_wm20201-na-sup"
* local using "//hume/rdc-gen/generations/soep-core/soep.v33_test/complete1/wmuki2"
* local clear "clear"

* check whether getfilename is installed
quietly capture findfile getfilename2.ado
if "`r(fn)'" == "" {
         di as txt "package getfilename2 needs to be installed first;"
         di as txt "use -ssc install getfilename2- to do that"
         exit 498
}

getfilename2 `pathwfile'
local fileroot = r(root)
local filepath = r(path)
if "`verbose'"=="verbose" {
	display "fileroot from getfilename2:`fileroot'"
}


	
quietly uselabel using "`using'", `clear'
if _N== 0 {
	quietly sysuse auto, `clear'
	uselabel, `clear'
	quietly keep if value==.
	quietly set obs 1
	quietly replace value=.
}
rename lname vallab
rename label ulabel
drop trunc
generate what=2
tempfile values
quietly save `values', replace

quietly use "`using'", `clear'
quietly describe, replace
quietly levelsof name, clean local(vars)
rename name variable
keep variable varlab vallab
preserve
quietly drop vallab
generate what=1
generate value=1
rename varlab ulabel
tempfile variablelabels
quietly save `variablelabels', replace
restore
drop varlab
generate what=2
quietly joinby vallab using `values', nolabel
quietly drop if value==.
drop vallab
quietly append using `variablelabels'
tempfile usingmeta
quietly save `usingmeta', replace

* local pathwfile "//hume/rdc-gen/consolidated/soep-core/soep.v33_test/consolidated1/wmuki2"
* local clear "clear"

uselabel using `"`filepath'/`fileroot'.dta"', `clear'
if _N== 0 {
	quietly sysuse auto, `clear'
	uselabel, `clear'
	quietly keep if value==.
	quietly set obs 1
	quietly replace value=.
}
rename lname vallab
rename label mlabel
drop trunc
generate what=2
tempfile values
quietly save `values', replace
* display `"`filepath'/`fileroot'"'
quietly use `"`filepath'/`fileroot'.dta"', `clear'
describe, replace
rename name variable
keep variable varlab vallab
preserve
drop vallab
generate what=1
generate value=1
rename varlab mlabel
tempfile variablelabels
quietly save `variablelabels', replace
restore
drop varlab
generate what=2
quietly joinby vallab using `values', nolabel
quietly drop if value==.
drop vallab 
quietly append using `variablelabels'

quietly merge 1:1 variable what value using `usingmeta'
quietly keep if mlabel!=ulabel
quietly if _N==0 set obs 1
quietly levelsof variable if what==1 & inlist(_merge, 2,3), clean local(varlab)
* display "`varlab'"
ereturn local varlab `varlab'
quietly drop if what==1
quietly if _N==0 set obs 1
quietly gen vallab =""
*quietly levelsof variable, clean local(vars) * moved up*
*display "`vars'"
foreach	variable of local vars {
	if _N==0 set obs 1
	quietly levelsof value if variable=="`variable'", clean local(vals)
	quietly replace vallab="`variable'(" + "`vals'" + ")" if variable=="`variable'"
}
capture quietly levelsof vallab if vallab!="" in 1, clean local(vallab)
if _rc!=0 {
	local vallab "TOO MUCH TO DISPLAY"
}
* display "`vallab'"
ereturn local vallab `vallab'

end
