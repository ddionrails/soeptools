/*-------------------------------------------------------------------------------
  soepcompletemd.ado: extract metadata of variable and export

    Copyright (C) 2019  Knut Wenzig (kwenzig@diw.de)

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
*! soepcompletemd.ado: extract metadata of variable and export
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.5.4 October 1, 2020 - soepcompletemd: import uses now option bindquote(strict); remove var label_en
*! version 0.4.2 June 18, 2019 - update soepcompletemd
*! version 0.4 June 17, 2019 - introduce soepinitdta, soepcompletemd, soeptranslituml, updates for v35

program define soepcompletemd, nclass
	version 15 
	syntax varname, targetfolder(string) [language(string) type(string) concept(string) after(string) before(string) study(string) dataset(string) version(string) template(numlist max=1) verbose]


* the ado opens variables.csv and variabe_categories.csv and inserts the metadata from the variable

if "`verbose'"=="verbose" {
	display "varname: `varlist'"
	display "targetfolder: `targetfolder'"
	display "language: `language'"
	display "type: `type'"
	display "concept: `concept'"
	display "study: `study'"
	display "dataset: `dataset'"
	display "version: `version'"
	display "template: `template'"
	display "verbose: `verbose'"
}

preserve

* sysuse auto, clear
*rename foreign sample1
* local targetfolder "D:/lokal/core-doku/datasets/ap/v35/"
* local varname "foreign"
* local language "de"
* local before "ahhnr"
* local after "ahhnr"
* local concept "neuesKonzept"
* local template 999

local langsuffix "_de"
if "`language'"=="en" local langsuffix
display "langsuffix: `langsuffix'"


local type : type `varlist'
display "type: `type'"
local strtest : piece 1 3 of "`type'"
if "`strtest'"=="str" local type "str"
display "type: `type'"
local varlabel : variable label `varlist'
display "varlabel: `varlabel'"
local vallabel : value label `varlist'
display "vallabel: `vallabel'"

uselabel `vallabel', replace
* if-statement needed for datasets without any value labels
if _N ==0 {
	sysuse auto, clear
	uselabel _all, replace
	keep if value==-1
}
if "`vallabel'"=="" keep if lname==""
keep value label
gen valuestring = string(value)
drop value
rename valuestring value
rename label label`langsuffix'
gen variable = "`varlist'"
tempfile vc_update
save `vc_update', replace

import delimited "`targetfolder'/variable_categories.csv", varnames(1) clear encoding("UTF-8") stringcols(_all) bindquotes(strict)
if _N > 0 {
	local study = study[1]
	local dataset = dataset[1]
	local version = version[1]
}
else {
	display "Options study, dataset and version are used for variable_categories.csv. The should not be empty."
}
keep if variable!="`varlist'"
append using `vc_update', nolabel nonotes
replace study = "`study'" if study==""
replace dataset = "`dataset'" if dataset==""
replace version = "`version'" if version==""

save `vc_update', replace

import delimited "`targetfolder'/variables.csv", varnames(1) clear encoding("UTF-8") stringcols(_all) bindquotes(strict)
if _N > 0 {
	local study = study[1]
	local dataset = dataset[1]
	local version = version[1]
}
else {
	display "Options study, dataset and version are used for variables.csv. The should not be empty."
}
gen part = 1
gen before = 1
gen after = 1
replace part = 2 if variable=="`varlist'"
replace part = 3 if part[_n-1]==2 | part[_n-1]==3
replace before = 3 if variable=="`before'"
replace before = 3 if before[_n-1]==3 
replace after = 2 if variable=="`after'"
replace after = 3 if after[_n-1]==2 | after[_n-1]==3
replace after = 1 if after==2

tempfile variablescsv
save `variablescsv', replace
tempfile beforepart
tempfile afterpart

if "`after'"!="" {
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if after == 1
	save `beforepart', replace
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if after == 3
	save `afterpart', replace
	display "Option after used."
}

if "`before'"!="" {
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if before == 1
	save `beforepart', replace
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if before == 3
	save `afterpart', replace
	display "Option before used, after overridden if specified."
}

if "`before'"=="" & "`after'"=="" {
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if part == 1
	save `beforepart', replace
	use `variablescsv', clear
	drop if variable == "`varlist'"
	keep if part == 3
	save `afterpart', replace
}
	
use `beforepart', clear
	
use `variablescsv', clear
keep if part==2
set obs 1
replace study = "`study'" if study==""
replace dataset = "`dataset'" if dataset==""
replace version = "`version'" if version==""
replace variable = "`varlist'" if variable==""
replace template_id = "`template'"
replace label = ""
replace label_en = ""
replace label`langsuffix' = "`varlabel'"
replace concept = "`concept'"
replace type = "`type'"
	
tempfile variablepart
save `variablepart', replace
clear
append using `beforepart' `variablepart' `afterpart'
drop part before after

export delimited using "`targetfolder'/variables.csv",  delimiter(",") replace
save `variablescsv', replace

keep study dataset version variable
gen varsort = _n
save `variablescsv', replace

use `vc_update', clear
gen sort = _n
merge m:1 study dataset version variable using `variablescsv', keep(match) nogenerate
sort varsort sort
drop varsort sort
export delimited using "`targetfolder'/variable_categories.csv",  delimiter(",") replace
save `vc_update', replace

restore

	
end
