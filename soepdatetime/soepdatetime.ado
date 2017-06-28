/*-------------------------------------------------------------------------------
  soepdatetime.ado: get date time

    Copyright (C) 2017  Knut Wenzig (kwenzig@diw.de)

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
*! soepdatetime.ado: returns datetime suitable for filenames
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.2.1 24 Mai 2017 - soepallcons: bugfix for emptyexcel exports

program define soepdatetime, rclass
	version 13 
	syntax , [verbose]

	
local date: display %td_CCYY-NN-DD date(c(current_date), "DMY")
local date = trim("`date'")
local time = c(current_time)
local time = subinstr(trim("`time'"), ":" , "-", .)

local datetime "`date'_`time'"

if "`verbose'"=="verbose" {
	display "result: `datetime'"	
}

return local datetime `"`datetime'"'

end
