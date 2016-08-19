/*-------------------------------------------------------------------------------
  soepinfra2ganze.ado: Recode isco88 from infratest to ganzeboom-variant

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
*! soepinfra2ganze.ado: Recode isco88 from infratest to ganzeboom-variant 
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! 20160620 version 0.8 20 June 2016 - soepgenpre: allow for string variables, bugfixes
*! version 0.1 13 April 2016 - initial release

program define soepinfra2ganze , nclass
	version 13
	syntax varname

generate `varlist'_ganzeboom88 = string(`varlist') if `varlist'>0 & `varlist'<9900
* 110 Soldaten werden zu [Armed forces, soldiers] [incl. Enlisted Man] 
* (niedrigste Soldatenkategorie in Ganzeboom-Tabelle)
replace `varlist'_ganzeboom88 = "5164" if `varlist'==110
* 7139 Ausbau- und verwandte Berufe, anderweitig nicht genannt (in ISCO88com nicht in ISCO-ilo/ganzeboom)
* werden zu 7130 BUILDING FINISHERS AND RELATED TRADES WORKERS
replace `varlist'_ganzeboom88 = "7130" if `varlist'==7139
* 2470  Wissenschaftliche Verwaltungsfachkräfte des öffentlichen Dienstes
* werden zu 2400 OTHER PROFESSIONALS [incl. Professional nfs, Administrative Professional]
replace `varlist'_ganzeboom88 = "2400" if `varlist'==2470

replace `varlist'_ganzeboom88 = `varlist'_ganzeboom88 + (4-length(`varlist'_ganzeboom88))*"0"  if `varlist'_ganzeboom88!=""
destring `varlist'_ganzeboom88, replace
soepapplyvaluelabel `varlist'_ganzeboom88, id(808)
local label  "Ganzebooms ISCO-88 variant of: `varlist'" 
label variable `varlist'_ganzeboom88 `"`label'"'
end
