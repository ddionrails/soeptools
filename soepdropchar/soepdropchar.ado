/*-------------------------------------------------------------------------------
  soepdropchar.ado: drop characteristics from a dataset

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
*! soepdropchar.ado: drop characteristics from a dataset
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.10 20 September 2016 - initial release


* soepdropchar

program define soepdropchar
    syntax [varlist] , [Dataset only]
    
    if "`dataset'" == "dataset" {
        local varlist _dta `varlist'
        if "`only'" == "only" local varlist "_dta"
    }
    
    foreach v in `varlist' {
        local ilist: char `v'[]
        foreach i in `ilist' {
            char `v'[`i']
        }
    }
end
