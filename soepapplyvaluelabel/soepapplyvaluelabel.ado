/*-------------------------------------------------------------------------------
  soepapplyvaluelabel.ado: Applies value label from templates to variables
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
*! soepapplyvaluelabel.ado: Applies value label from templates to variables
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.10 (20160808) - introduce soepapplyvaluelabel/soepfitsclass

program define soepapplyvaluelabel, rclass
	version 13
syntax varlist [using/] , id(string) [language(string) utf2cp lblname(string)]

tempfile myfile
quietly save `myfile', replace

if "`using'"=="" local using "https://gitlab.soep.de/kwenzig/additionalmetadata/raw/master/templates/"

if "`utf2cp'"=="utf2cp"{
	soeputf2cp using "`using'/values_templates.csv", topath(tmpdir) copy verbose
	return list
	local using = r(path)
}

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear
display "imported"

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
keep value label`language_suffix'
isid value

local rows = _N

forvalues row = 1/`rows' {
	local value_`row' = value[`row']
	local label_`row' = label`language_suffix'[`row']
}

use `myfile', clear

if "`lblname'"=="" {
	local lblname t`id'
	local lblname : subinstr local lblname " " ""
	local lblname : subinstr local lblname "," "_"
}
capture label drop `lblname'

forvalues row = 1/`rows' {
	label define `lblname' `value_`row'' "`label_`row''", add
}

label values `varlist' `lblname'

return local lblname `lblname'
end	
