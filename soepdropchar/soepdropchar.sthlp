{smcl}
{* *! version 0.10}{...}
help for {cmd:soepdropchar}{right:version 0.10 20 September 2016}
{hline}

{title:soepdropchar}

{phang}
{bf:soepdropchar} {hline 2} drop characteristics from a dataset


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepdropchar} {help varlist:{it:varlist}}, [{opt dataset}  {opt only}]{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt dataset}}drop also characteristics from dataset{p_end}
{synopt:{opt only}}drop only dataset's characteristics{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{marker examples}{...}
{title:Example}

{pstd}
Delete only the characteristics of a dataset:

	{cmd:soepdropchar, dataset only}


{marker remarks}{...}
{title:Remarks}

{pstd}
This command is inspired by Robert Picard's {browse "http://www.statalist.org/forums/forum/general-stata-discussion/general/1291200-how-do-i-delete-all-characteristics-from-a-dataset?p=1291203#post1291203":comment} on statalist.org.
{p_end}

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

