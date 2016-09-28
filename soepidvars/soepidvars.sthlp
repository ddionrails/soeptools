{smcl}
{* *! version 0.12 28 September 2016}{...}
help for {cmd:soepidvars}{right:version 0.12  (28 September 2016)}
{hline}


{title:Title}

{phang}
{bf:soepidvars} {hline 2} Varlist which uniquely identifies oberservations in SOEP data


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepidvars}, [{opt verbose}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt verbose}}display the varlists which are actually examined{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:soepidvars} makes an educated guess for each SOEP dataset and tries to find a list of variables which uniqueliy identifies the oberservations (rows). There are three scenarios which are examined: whether it is a dataset from an interviewed person, a household or an interviewer. If a solution is found, which means {help isid} returns no error, the result is returned in r(idvars). The configured possible idvars to search for are also returned for each scenario.


{marker examples}{...}
{title:Example}

{pstd}
For all datasets in one path: store all found varlists in a table:

	{cmd:set more off                                                }
	{cmd:local usedir "\\hume\soep-data\DATA\soep31_de\stata\"       }
	{cmd:local files : dir `"`usedir'"' files "*.dta"                }
	{cmd:display `"`files'"'                                         }
	{cmd:foreach file of local files {c -(}       }
	{cmd:	local fileurl "`usedir'/`file'"       }
	{cmd:	use `fileurl', clear                  } 
	{cmd:	getfilename2 `fileurl'                }
	{cmd:	local root = "`r(root)'"              }
	{cmd:	soepidvars                            }
	{cmd:	local ids_`root' = "`r(idvars)'"      }
	{cmd:	local roots = "`roots' `root'"        }
	{cmd:	display "`file': `ids_`root''"        }
	{cmd:{c )-}                                   }
	{cmd:clear                                    }
	{cmd:local filesn : word count `files'        }
	{cmd:set obs `filesn'                         }
	{cmd:gen str dataset = ""                     }
	{cmd:gen str idvars = ""                      }
	{cmd:forvalues i = 1/`filesn' {c -(}          }
	{cmd:	local dataset : word `i' of `roots'   }
	{cmd:	local idvars = "`ids_`dataset''"      }
	{cmd:	replace dataset = "`dataset'" in `i'  }
	{cmd:	replace idvars = "`idvars'" in `i'    }
	{cmd:{c )-}                                   }


{marker remarks}{...}
{title:Remarks}

{pstd}
This command is part of the {browse "http://ddionrails.org/soeptools":soeptools} bundle. Please inform the author about issues using this {browse "https://github.com/ddionrails/soeptools/issues":tracker}.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}

{marker author}{...}
{title:Author}

{pstd}
Knut Wenzig ({browse "mailto:kwenzig@diw.de":kwenzig@diw.de}), DIW Berlin, German Socio-Economic Panel (SOEP), Germany.
{p_end}

