/*-------------------------------------------------------------------------------
  soepopenclass.ado: Opens classification
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
*! soepopenclass.ado: Opens classification
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! 20160623 version 0.9 23 June 2016 - introduce soepfitsclass.ado
*! version 0.9 23 June 2016 - introduce soepfitsclass.ado

program define soepopenclass
	version 13
syntax [using/] , id(string) [value(string) noinfo] clear

*debug
*local varlist "v_kldb2010raw"
*local id "800"

if "`clear'"!="clear" {
	display "Option clear mandatory."
	exit
}

if "`using'"=="" local using "D:/lokal/additionalmetadata/templates/"

if "`noinfo'"!="noinfo" {
	soepclassinfo using `using', id(`id')	
}

quietly import delimited "`using'values_templates.csv", delimiter(comma) varnames(1) ///
	numericcols(1 2 3) stringcols (4 5 6) clear
quietly keep if inlist(id,`id')

if "`value'"!="" {
	quietly keep if inlist(value,`value')
}

end	
