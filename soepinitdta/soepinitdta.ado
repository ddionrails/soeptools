/*-------------------------------------------------------------------------------
  soepinitdta.ado: init dataset from metadata

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
*! soepinitdta.ado: init dataset from metadata
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany

* version 0.4.5 August 8, 2019 - soepinitdta: ad space to numlabel
* version 0.4.3 August 2, 2019 - soepinitdta: make key vars from list long
* version 0.4 June 17, 2019 - introduce soepinitdta, soepcompletemd, updates for v35

program define soepinitdta, nclass
	version 15 
	syntax, mdpath(string) [study(string) dataset(string) version(string) soepstyle verbose]
	
/* for debugging
local mdpath "https://git.soep.de/kwenzig/publicecoredoku/raw/master/datasets/bijugend/v35/"
local study "soep-core"
local dataset "bijugend"
local version "v35"
local soepstyle soepstyle
local verbose verbose
*/
	
* the ado opens variables.csv and variabe_categories.csv and constructs an empty
* dta-file 

*quietly capture findfile distinct.ado
*if "`r(fn)'" == "" {
*         di as txt "package distinct needs to be installed first;"
*         di as txt "use -ssc install distinct- to do that"
*         exit 498
*}

if "`verbose'"=="verbose" {
	display "Options:"
	display "mdpath: `mdpath'"
	display "dataset: `dataset'"
	display "version: `version'"
	display "verbose: `verbose'"
}

* store all possible names of keyvariables to local keys
quietly: import delimited "https://git.soep.de/kwenzig/publicecoredoku/raw/master/meta/logical_datasets.csv", ///
				delimiter(comma) bindquote(strict) case(preserve) ///
				encoding(utf8) stringcols(_all) clear
quietly: keep if primary_keys!=""
quietly: keep primary_keys
quietly: duplicates drop primary_keys , force
quietly: levelsof primary_keys, clean local(keys)
local keys : list uniq keys

if "`verbose'"=="verbose" {
	display "Key variables form logical_dtaasets.csv: `keys'."
}

* restrict on attributes from options (study, dataset, version) and assert that
* - table contains only one study, dataset and version and 
* - each variable apprears only once

if "`verbose'"=="verbose" {
	display "Open variables.csv."
}

quietly: import delimited "`mdpath'variables.csv", ///
	delimiter(comma) bindquote(strict) case(preserve) ///
	encoding(utf8) stringcols(_all) clear

if "`study'"!="" {
	quietly: keep if study=="`study'"
}
if "`dataset'"!="" {
	quietly: keep if dataset=="`dataset'"
}
if "`version'"!="" {
	quietly: keep if version=="`version'"
}	

quietly: levelsof study
assert r(r)==1
quietly: levelsof dataset
assert r(r)==1
quietly: levelsof version
assert r(r)==1

isid variable

local numberofvars = _N

* Umlaute ausschreiben
if "`soepstyle'"=="soepstyle" {
	soeptranslituml label label_de
}

forvalues row = 1/`numberofvars' {
			local var_`row' = variable[`row']
			local type_`row' = type[`row']			
			* Workaround for backticks in Label
			local labeltext = label_de[`row']
			local labeltext: subinstr local labeltext  "`" "'"
			local label_`row' = `"`labeltext'"'
}

gen varorder = _n
* liste der nicht-string-Variablen
quietly: drop if type=="str"
quietly: keep study dataset version variable varorder
tempfile nonstringvariables
quietly: save `nonstringvariables', replace

if "`verbose'"=="verbose" {
	display "variables.csv opened and processed."
}

if "`verbose'"=="verbose" {
	display "Open variable_categories.csv."
}
quietly: import delimited "`mdpath'variable_categories.csv", ///
	delimiter(comma) bindquote(strict) case(preserve) ///
	encoding(utf8) stringcols(_all) clear

* value erst numerisch machen
quietly: drop if value==""
rename value valuestring
gen value=real(valuestring)
drop valuestring

* Umlaute ausschreiben
if "`soepstyle'"=="soepstyle" {
	soeptranslituml label label_de
}

* nur die Zeilen behalten, die zur variables passen
quietly: merge m:1 study dataset version variable using `nonstringvariables', keep(match) nogen

isid study dataset version variable value

sort varorder value
bysort varorder: gen valueorder=_n
bysort varorder: gen noofvalues=_N
local numberofrows = _N

if `numberofrows'>0 {
	forvalues row = 1/`numberofrows' {
		local varorder = varorder[`row']
		local valueorder = valueorder[`row']
		local valuevar_`varorder' = variable[`row']
		local value_`varorder'_`valueorder' = value[`row']			
		* Workaround for backticks in Label
		local labeltext = label_de[`row']
		local labeltext: subinstr local labeltext  "`" "'"
		local label_`varorder'_`valueorder' = `"`labeltext'"'
	}

	keep varorder noofvalues
	quietly: duplicates drop _all, force
	local numberofrows = _N

	* alle Value-Labels erzeugen
	label drop _all  
	
	forvalues labelno = 1/`numberofrows' {
		local varorder = varorder[`labelno']
		local noofvalues = noofvalues[`labelno']
		forvalues valueorder = 1/`noofvalues' {
			*display "define: `valuevar_`varorder''"
			*display "varorder: `varorder'"
			label define `valuevar_`varorder'' `value_`varorder'_`valueorder'' `"`label_`varorder'_`valueorder''"', add
			*if "`valuevar_`varorder''"=="bij_30_q121" {
			*	display "`valuevar_`varorder'' `value_`varorder'_`valueorder'' `label_`varorder'_`valueorder''"
			*}
		}
	}
	if "`verbose'"=="verbose" {
		display "variable_categories.csv opened and processed."
	}
}
else {
	if "`verbose'"=="verbose" {
		display "No value labels."
	}
}

label list bij_30_q121

* neuen Datensatz erzeugen
if "`verbose'"=="verbose" {
	display "Create dataset."
}

drop _all	
forvalues row = 1/`numberofvars' {
			local variable = "`var_`row''"
			local vallabel
			*display "row: `row'"
			*display "lookfor: `variable'"
			capture label list `variable'
			if _rc==0 {
				* display "found: `variable'"
				local vallabel = ":`variable'"
			}
			*capture label list label_`row'
			*if _rc==0 local vallabel = ":label_`row'"
			*display "vallabel: `vallabel'"
			local type = "`type_`row''"
			local format "%12.0g"
			if !inlist("`type'","byte","int","long","float","double","str"){
				local type = "byte"
				}			
			local variable = "`var_`row''"
			local temppos : subinstr local keys "`variable'" "", all word count(local tempnumber)
			*local found = `tempnumber'>0
			*display "found `found'"
			*if inlist("`variable'","pid","hid","syear","pnrfest","hhnrakt","hhnr","persnr","hhnrakt","spellnr") | ///
			*	inlist("`variable'","vpnr","kennung","survey_year","no_of_treatment","vpersnr","bikennung","bioage","bisurvey_year","bino_of_treatment") | ///
			*	inlist("`variable'","cid","intnum","intnr","biintid","intid","intnr_tns","mignr","mj","vpid") | ///
			*   inlist("`variable'","zvpnr","persnre","bivpnr"){
			if `tempnumber'>0 {
				local type = "long"
				local format "%12.0g"
				if "`verbose'"=="verbose" {
					display "Key variable `variable' set to long."
				}
			}
			local label = `"`label_`row''"'
			if "`type'"=="str" {
				gen `type' `variable'= ""
			}
			else {
				gen `type' `variable'`vallabel'= .
				format `format' `variable'
			}
			label variable `variable' `"`label'"'
}

if "`soepstyle'"=="soepstyle" {
	numlabel, remove mask("[#]") force
	numlabel, add mask("[#] ") force
}

if "`verbose'"=="verbose" {
	display "New dataset available."
}
	
end
