/*-------------------------------------------------------------------------------
  soepclassinfo.ado: Displays info of a list of classification ids
    Copyright (C) 2020  Knut Wenzig (kwenzig@diw.de)
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
*! soepclassinfo.ado: Displays info of a list of classification ids
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
* version 0.5 July 2, 2020 - soepinitdta: seperate options for numlabel and translitumlauts, typos soepclassinfo
* version 0.9 23 June 2016 - introduce soepfitsclass.ado
* version 0.9 23 June 2016 - introduce soepfitsclass.ado

program define soepclassinfo, rclass
	version 13
syntax [using/] , id(string)

preserve

if "`using'"=="" local using "D:/lokal/additionalmetadata/templates/"

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear
quietly keep if inlist(id,`id')
tempfile thisclass
quietly save `thisclass', replace // tempfile mit zulässigen Angaben

* Infos extrahieren
keep id info
* sicherstellen, dass nur eine Zeile pro id bleibt
* 1. Zeilen mit leerem info löschen
quietly keep if info!=""
* 2. duplicate löschen
quietly duplicates drop id info, force
* 3. nur die erste Zeile pro id erhalten
tempvar rowcount
bysort id: gen `rowcount' = _n
quietly keep if `rowcount'==1
tempfile infos
quietly save `infos', replace

use `thisclass', clear
drop info
bysort id: generate n = _N
bysort id: egen from = min(value)
bysort id: egen to = max(value)
bysort id: gen `rowcount' = _n
quietly keep if `rowcount'==1

quietly merge 1:1 id using `infos', assert(master match) nogen noreport

forvalues row = 1/`=_N' {
	local id = id[`row']
	local info = info[`row']
	local n = n[`row']
	local from = from[`row']
	local to = to[`row']
	display "`id': `info' (n: `n', from: `from', to: `to')"
}

restore
end	
