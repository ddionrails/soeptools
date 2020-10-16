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
*! version 0.5.5 October 16, 2020 - soepapplyvaluelabel: use new default repo for templates
*! version 0.5.2 July 6, 2020 - soepapplyvaluelabel: seperate options for numlabel and translitumlauts
*! version 0.3.3 4 July 2018 - soepapplyvalues: switch repo and introduce soepstyle
*! version 0.10 (20160808) - introduce soepapplyvaluelabel/soepfitsclass

program define soepapplyvaluelabel, rclass
	version 14
syntax varlist [using/] , id(string) [language(string) encoding(string) lblname(string) numlabel translitumlauts]

tempfile myfile
quietly save `myfile', replace

if "`using'"=="" local using "https://git.soep.de/kwenzig/publicadditionalmetadata/-/raw/master/templates/"

if "`encoding'"=="" local encoding "utf-8"

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) encoding("`encoding'") clear
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
	
display "id: `id'"	
quietly keep if inlist(id,`id')
keep value label`language_suffix'
isid value

local rows = _N
display "rows: `rows'"

* Umlaute ausschreiben und numlabel ersetzen
if "`translitumlauts'"=="translitumlauts" {
	soeptranslituml label`language_suffix'
}
if "`numlabel'"=="numlabel" {
	gen soepnumlabel = "["+string(value)+"] "

	gen pos = ustrpos(label`language_suffix',soepnumlabel)
	clonevar label_new = label`language_suffix'
	replace label_new = usubinstr(label_new,soepnumlabel,"",1) if pos==1
	replace label_new = soepnumlabel + label_new
	drop label`language_suffix' pos
	rename label_new label`language_suffix'
}


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
display "Variable: `varlist' labed with label `lblname'"
return local lblname `lblname'
end	
