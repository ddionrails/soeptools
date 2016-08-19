/*-------------------------------------------------------------------------------
  soeputf2cp.ado: convert UTF-8 file to cp1252

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
*! soepidvars.ado: convert UTF-8 file to cp1252
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.10 (20160808) - introduce soepapplyvaluelabel/soepfitsclass/soeputf2cp

program define soeputf2cp, rclass
	version 13
	syntax using/ [, topath(string) iconvpath(string) verbose copy]

if "`iconvpath'"==""  {
	local iconvpath "c:\strawberry\c\bin\"	
}
if "`verbose'" == "verbose" {
 display "iconvpath: _`iconvpath'_"
 display "using: _`using'_"
}

local iconvoptions `"--unicode-subst="-" -f UTF-8 -t cp1252"'
getfilename2 "`using'"
local root = r(root)
local ext = r(ext)
local path = r(path)
local path "`path'/"
if "`verbose'" == "verbose" {
	display "path (from using): _`path'_"
	display "root (from using): _`root'_"
	display "ext  (from using): _`ext'_"
}


if "`topath'"=="" {
	local topath = "`path'"
	if "`verbose'" == "verbose" {
		display "topath (was empty): _`topath'_"
	}
}

if "`topath'"=="tmpdir" {
	local topath = c(tmpdir)
	if "`verbose'" == "verbose" {
		display "topath (was tmpdir): _`topath'_"
	}
}

if "`copy'"=="copy" {
	copy "`using'" "`topath'/`root'.utf8.`ext'", replace
	local using "`topath'/`root'.utf8.`ext'"
}

if "`verbose'" == "verbose" {
	display "topath (final): _`topath'_"	
}

local target "`topath'/`root'.`ext'"

if "`verbose'" == "verbose" {
	display "target (final): _`target'_"	
}

local cmd `"`iconvpath'iconv `iconvoptions' "`using'" > "`target'" & timeout 2"'

if "`verbose'" == "verbose" {
	display `"cmd (final): _`cmd'_"'	
}

! `cmd'
return local pathfile `target'
return local path `topath'

end





