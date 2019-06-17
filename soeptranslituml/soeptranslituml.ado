/*-------------------------------------------------------------------------------
  soeptranslituml.ado: transliteration for umlauts and other non-ascii-chars

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
*! soeptranslituml.ado: transliteration for umlauts and other non-ascii-chars
*! Knut Wenzig (kwenzig@diw.de), SOEP, DIW Berlin, Germany
*! version 0.4 June 17, 2019 - introduce soepinitdta, soepcompletemd, soeptranslituml, updates for v35

program define soeptranslituml, nclass
	version 15 
	syntax varlist	


* the ado translitarates umlauts and other non-ascii-characters to ascii (A-Z,a-z)

foreach variable of local varlist{
	* display "`variable'"
	local type : type `variable'
	* nimm erste 3 Buchstaben:
	local type : piece 1 3 of "`type'"
	* display "`type'"
	if "`type'" == "str" {
		quietly {
			replace `variable' = ustrregexra(`variable',"ä","ae")
			replace `variable' = ustrregexra(`variable',"ö","oe")
			replace `variable' = ustrregexra(`variable',"ü","ue")
			replace `variable' = ustrregexra(`variable',"ß","ss")
			replace `variable' = ustrregexra(`variable',"Ä","AE")
			replace `variable' = ustrregexra(`variable',"Ö","OE")
			replace `variable' = ustrregexra(`variable',"Ü","UE")		
			* Französische Sonderzeichen
			* https://de.wikipedia.org/wiki/Franz%C3%B6sisches_Alphabet
			replace `variable' = ustrregexra(`variable',"À","A")
			replace `variable' = ustrregexra(`variable',"Â","A")
			replace `variable' = ustrregexra(`variable',"Æ","AE")
			replace `variable' = ustrregexra(`variable',"Ç","C")
			replace `variable' = ustrregexra(`variable',"È","E")
			replace `variable' = ustrregexra(`variable',"É","E")
			replace `variable' = ustrregexra(`variable',"Ê","E")
			replace `variable' = ustrregexra(`variable',"Ë","E")
			replace `variable' = ustrregexra(`variable',"Î","I")
			replace `variable' = ustrregexra(`variable',"Ï","I")
			replace `variable' = ustrregexra(`variable',"Ô","O")
			replace `variable' = ustrregexra(`variable',"Œ","OE")
			replace `variable' = ustrregexra(`variable',"Ù","U")
			replace `variable' = ustrregexra(`variable',"Û","U")
			replace `variable' = ustrregexra(`variable',"Ü","U")
			replace `variable' = ustrregexra(`variable',"Ÿ","Y")
			replace `variable' = ustrregexra(`variable',"à","a")
			replace `variable' = ustrregexra(`variable',"â","a")
			replace `variable' = ustrregexra(`variable',"æ","a")
			replace `variable' = ustrregexra(`variable',"ç","c")
			replace `variable' = ustrregexra(`variable',"è","e")
			replace `variable' = ustrregexra(`variable',"é","e")
			replace `variable' = ustrregexra(`variable',"ê","e")
			replace `variable' = ustrregexra(`variable',"ë","e")
			replace `variable' = ustrregexra(`variable',"î","i")
			replace `variable' = ustrregexra(`variable',"ï","i")
			replace `variable' = ustrregexra(`variable',"ô","o")
			replace `variable' = ustrregexra(`variable',"œ","oe")
			replace `variable' = ustrregexra(`variable',"ù","u")
			replace `variable' = ustrregexra(`variable',"û","u")
			replace `variable' = ustrregexra(`variable',"ü","ue")
			replace `variable' = ustrregexra(`variable',"ÿ","y")		
		}
	}
}
	
end
