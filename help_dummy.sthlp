{smcl}
{* *! VERSION_NUMBER_DATE_FROM_SOEPTOOLS.PKG}{...}
help for {cmd:COMMANDNAME}{right:VERSION_NUMBER_DATE_FROM_SOEPTOOLS.PKG}
{hline}


{title:Title}

{phang}
{bf:COMMANDNAME} {hline 2} DISCRIPTION_LINE_FORM_ADO


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:COMMANDNAME} {help filename:{it:filename}} {cmd:using} {it:pathname}, {opt clear} [{opt keyvars(varlist)}  {opt verbose}]{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt OPTION1}}display the varlists which are actually examined{p_end}
{synopt:{opt OPTION2()}}which variables should be used for merging. If not specified {help soepidvars} is used for an educated guess.{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:COMMAND} bla bla {help isid} {it:pathname} {help filename:{it:filename}} {opt keyvars}.


{marker examples}{...}
{title:Example}

{pstd}
For all datasets in one path: store all found varlists in a table:

	{cmd:set more off                                                }


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

