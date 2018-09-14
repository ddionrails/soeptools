/*-------------------------------------------------------------------------------
  soepmergeclass.ado: merges value_templates to a variable
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
*! soepmergeclass.ado: merges value_templates to a variable
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.3.11 14 September 2019 - soepmergeclass: switch encoding (of ado), remove utf2cp option, switch default repo
*! version 0.9 23 June 2016 - introduce soepfitsclass.ado

program define soepmergeclass, rclass
	version 14
syntax varname [using/] , id(string) [verbose force language(string)]

*debug
*local varlist "v_kldb2010raw"
*local id "800"

tempfile myfile
quietly save `myfile', replace

if "`using'"=="" local using "https://git.soep.de/kwenzig/additionalmetadata/raw/master/templates/"

quietly import delimited "`using'/values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear encoding("utf-8")  

if "`language'"	== "de" {
	local language_suffix _de
} 
else if "`language'" == "en" {
	local language_suffix
} 
else {
	local language_suffix _de
}

quietly keep if inlist(id,`id')
rename label`language_suffix' _label
rename value _value
keep _value _label
isid _value

tempfile thisclass
quietly save `thisclass', replace // tempfile mit zulässigen Angaben

* Überprüfung, ob nur zulässige Angaben angenommen werden
quietly use `myfile', clear
tempvar `value'
generate _value = `varlist'

* 
merge m:1 _value using `thisclass'
rename _merge _inclass
label define _inclass 1 "value only used in data" ///
                      2 "value only used in classification" ///
					  3 "value used in data and classification", replace
label values _inclass _inclass 

end
/*
local rc = _rc
if `rc' == 0 {
	display "All values fit classification."
}
else {
	display "Not all values fit classification."
	display "_merge==1 are cases with values not from classification."
	if "`force'"!="force" exit
}
* Überprüfung, ob nur zulässige Angaben als value label definiert sind
quietly use `file', clear
local lblname : value label `varlist'
uselabel `lblname', clear
quietly capture merge 1:1 value using `thisclass', assert(match)
local rc = _rc
if `rc' == 0 {
	display "All value labels fit classification."
	quietly use `myfile', clear
}
else {
	display "Not all value labels fit classification."
	display "_merge == 1 are labeled values but not in classification."
	display "_merge == 2 are in classification but not in value label."
	if "`force'"!="force" exit
	if "`force'"=="force" quietly use `myfile', clear
}
end	
*/
