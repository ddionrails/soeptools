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
*! 20160623 version 0.9 23 June 2016 - introduce soepfitsclass.ado
*! version 0.9 23 June 2016 - introduce soepfitsclass.ado

program define soepfitsclass, rclass
	version 13
syntax varname [using/] , id(string) [verbose force]

*debug
*local varlist "v_kldb2010raw"
*local id "800"

if _N==0 {
	display "No Observations. Abort check."
	exit
}

tempfile myfile
quietly save `myfile', replace

tempfile file
keep `varlist'
quietly save `file', replace

local lblname : value label `varlist'
uselabel `lblname', clear
drop lname trunc
tempfile usedlabel
quietly save `usedlabel', replace

if "`using'"=="" local using "D:/lokal/additionalmetadata/templates/"

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear
quietly keep if inlist(id,`id')
keep value label_de

tempfile thisclass
quietly save `thisclass', replace // tempfile mit zulässigen Angaben

if "`verbose'"=="verbose" {
	soepclassinfo using `using', id(`id')
}

* Überprüfung, ob nur zulässige Angaben angenommen werden
quietly use `file', clear
rename `varlist' value
* genutze Wertelabel anmergen
quietly capture merge m:1 value using `usedlabel', keep(master match) nogen
* Werte müssen entweder vorhanden sein (match) oder dürfen nur in der Klassifikation sein (using)
quietly capture merge m:1 value using `thisclass', keep(master match) assert(match using)
local rc = _rc
if `rc' == 0 {
	display "All realized values appear in classification."
}
else {
	display "Not all realized values appear in classification."
	if "`verbose'"=="verbose" {
		quietly keep if _merge ==1
		label values value
		bysort value: gen n=_N
		list value n label, compress table
	}
	/*if "`force'"!="force" {
		display "_merge==1 are cases with values not from classification."
		exit
	}*/
}
* Überprüfung, ob nur zulässige Angaben als value label definiert sind
* Häufigkeiten (n) 
quietly use `file', clear
rename `varlist' value
quietly keep value
bysort value: gen n=_N
quietly duplicates drop value , force
tempfile frequencies
quietly save `frequencies', replace

quietly use `file', clear
local lblname : value label `varlist'
if "`lblname'"=="" {
	display "Variable hast no value label."
	quietly use `myfile', clear
	exit
}

uselabel `lblname', clear
quietly capture merge 1:1 value using `thisclass', assert(match)
local rc = _rc
quietly capture merge 1:1 value using `frequencies', keep(master match) nogen
quietly replace n=0 if n==.
if `rc' == 0 {
	display "Value label and classification are defined for same values."
	quietly use `myfile', clear
}
else {
	quietly count if _merge ==1
	local count = r(N)
	display 
	if `count'> 0 {
		display "`count' labeled value(s) not used in classification."
		if "`verbose'"=="verbose" {
			sort value
			list value n label if _merge==1, compress table
		}
	}
	quietly count if _merge ==2
	local count = r(N)
	if `count'> 0 {
		display "`count' value(s) defined in classification but not used in value label."
		if "`verbose'"=="verbose" {
			sort value
			list value n label_de if _merge==2, compress table
		}
	}
	/*if "`force'"!="force" {
		display "_merge == 1 are labeled values but not in classification."
		display "_merge == 2 are in classification but not in value label."
		exit
	}*/
	if "`force'"!="force" exit
	if "`force'"=="force" quietly use `myfile', clear
}
end	
