/*-------------------------------------------------------------------------------
  soepinfra2com.ado: Recode isco88 from infratest to com-variant

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
*! soepinfra2com.ado: Recode isco88 from infratest to com-variant 
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! 20160620 version 0.8 20 June 2016 - soepgenpre: allow for string variables, bugfixes
*! version 0.1 13 April 2016 - initial release

program define soepinfra2com , nclass
	version 13
	syntax varname

capture drop `varlist'_com88
generate `varlist'_com88 = string(`varlist') if `varlist'>0 & `varlist'<9900 & `varlist'!=110
replace `varlist'_com88 = `varlist'_com88 + (4-length(`varlist'_com88))*"0" if `varlist'_com88!=""
destring `varlist'_com88, replace

* 110 Soldaten werden zu 100[Armed forces, soldiers] [incl. Enlisted Man] 
* (niedrigste Soldatenkategorie in Ganzeboom-Tabelle)
replace `varlist'_com88 = 100 if `varlist'==110

* 9331 Führer/-innen v. Handwagen und
* 9332 Führer/-innen v. Fahrz. mit Zugtierantr. (beides nicht in com)
* werden zu 9330 Transport- und Frachtarbeiter
replace `varlist'_com88 = 9330 if inlist(`varlist',9331,9332)

soepapplyvaluelabel `varlist'_com88, id(809)
label variable `varlist'_com88 "ISCO-88 (COM) variant of: `varlist'"
end
