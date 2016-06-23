/*-------------------------------------------------------------------------------
  soepfitsclass.ado: Checks whether a variable fits to classification
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
*! soepfitsclass.ado: Checks whether a variable fits to classification
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! 20160623 version 0.9 23 June 2016 - introduce soepisclass.ado
*! version 0.9 23 June 2016 - introduce soepisclass.ado

program define soepfitsclass, rclass
	version 13
syntax varname [using/] , id(string) [verbose force]

tempfile myfile
quietly save `myfile', replace

tempfile file
keep `varlist'
quietly save `file', replace

if "`using'"=="" local using "D:/lokal/additionalmetadata/templates/"

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear

quietly keep if inlist(id,`id')
keep value label_de

tempfile thisclass
quietly save `thisclass', replace // tempfile mit zulässigen Angaben

* Überprüfung, ob nur zulässige Angaben angenommen werden
quietly use `file', clear
rename `varlist' value
quietly capture merge m:1 value using `thisclass', keep(master match) assert(match)
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
