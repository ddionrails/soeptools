/*-------------------------------------------------------------------------------
  soepidvars.ado: varlist which uniquely identify oberservations

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
*! soepidvars.ado: varlist which uniquely identify oberservations
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.5.9 July 3, 2023 - soepcidvars: use option bindquotes
*! version 0.4 June 17, 2019 - introduce soepinitdta, soepcompletemd, soeptranslituml, updates for v35
*! version 0.3.11 14 September 2019 - soepidvars: introduce required variables in person scenario
*! version 0.3.2 4 July 2017 - soepidsvars: return nothing, if no keyvar is found
*!                             soepnextcons: use keyvars from complete file
*! version 0.14 29 September 2016 - soepidvars: bugfix (ignore isid hhnr in personal files)
*! version 0.12 28 September 2016 - soepidvars: ignore isid hhnr in personal files
*! version 0.3 19 April 2016 - initial release

program define soepidvars, rclass
	version 13 
	syntax , [dataset(string) verbose]
	

* the ado calulates the intersection of the datasets's variables and this three variablelists
* then it checks whether a subset checks, whether a subset of this variables uniquely identifies the obeservations
* the subsets start from the beginning and include in each step one more variable

* this variable lists contain the know id variables of all datasets
* for datasets of persons, households and interviewers	
if "`dataset'"=="" {
	local pidsreq persnr zvpnr vpnr persnre kidprofr persnrm
	local pids persnr zvpnr vpnr persnre kidprofr persnrm spellnr bioage mignr syear svyyear erhebj kennung hhnr
	local hids hhnrakt erhebj svyyear syear kennung spellnr mj hhnr
	local iids intnr intnr_tns intid intnum intid syear

	quietly ds
	local mastervars = r(varlist)

	* instersection of lists
	local testiids : list iids & mastervars
	local testhids : list hids & mastervars
	local testpids : list pids & mastervars
	local testpidsreq : list pidsreq & mastervars
	if "`testpids'"=="hhnr" local testpids ""
	if "`verbose'"=="verbose" {
		display "Found variables for each scenario:"
		display "person required list: `testpidsreq'"
		display "person: `testpids'"
		display "household: `testhids'"
		display "interviewer: `testiids'"
	}

	* if none of required variables for scenario person available, empty list for person scenario
	local numberpidsreq: word count `testpidsreq'
	if `numberpidsreq'==0 {
		local testpids
	}

	* first the list for datasets of persons, then households, then interviewers
	* if one list meets the isid-requirements exit the loop
	* and return the list
	* otherwise the returned list ist empty
	local alllists testpids testhids testiids

	foreach varlist of local alllists {
		if "`verbose'"=="verbose" {
			if "`varlist'"=="testpids" display "Test scenario 'person'."
			if "`varlist'"=="testhids" display "Test scenario 'household'."
			if "`varlist'"=="testiids" display "Test scenario 'interviewer'."
		}
		local testids ""
		foreach var of local `varlist' {
			local testids = "`testids' `var'"
			if "`verbose'"=="verbose" {
				display "  Test variables: `testids'"
			}
			capture isid `testids'
			if _rc==0 {
				local found "yes"
				if "`verbose'"=="verbose" {
					display "For the above varlist isid returned no error."
				}
				continue, break
			}
		
		}
		if "`found'"=="yes" {
			continue, break
		}
		else {
			local testids ""
		}
	}
	return local idvars `testids'
	return local config_idvars_p `pids'
	return local config_idvars_h `hids'
	return local config_idvars_i `iids'
}
if "`dataset'"!="" {
	tempfile temp1
	save `temp1', replace
	quietly: import delimited  "https://git.soep.de/kwenzig/publicecoredoku/raw/master/meta/logical_datasets.csv", varnames(1) clear encoding("UTF-8") bindquotes(strict)
	quietly: keep if dataset=="`dataset'"
	local testids = primary_keys[1]	
	use `temp1', clear
	return local idvars `testids'
}
end
		