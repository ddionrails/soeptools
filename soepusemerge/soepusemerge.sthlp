{smcl}
{* *! version 0.15 29 September 2016}{...}
help for {cmd:soepusemerge}{right:version 0.15 29 September 2016}
{hline}

{title:Title}

{phang}
{bf:soepusemerge} {hline 2} Open a template file and integrate variables from related files.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepusemerge} {help filename:{it:filename}} {cmd:using} {it:pathname}, {opt clear} [{opt keyvars(varlist)}  {opt verbose}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt clear}}necessary because data in memory will be replaced{p_end}
{synopt:{opt keyvars()}}which variables should be used for merging. If not specified {help soepidvars} is used for an educated guess.{p_end}
{synopt:{opt verbose}}produces much more output{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:soepusemerge} opens dataset {help filename:{it:filename}} and merges variables from all related datasets in {it:pathname}, performing a merge 1:1 with key variables specified in the option {opt keyvars} while requiring (1.) {opt keyvars} of type long, (2.) a complete match with assert(match), and (3.) merging only variables without missings.

{pstd}
A related dataset must have the name of the filename plus a suffix which start with an underscore. Example: filename is root.dta, a file in {it:pathname} with name root_xy.dta would be recognized as related.
{p_end}

{pstd}
Results can be inspected with {help return:ereturn list}.
{p_end}


{marker remarks}{...}
{title:Remarks}

{pstd}
This command is part of the {browse "http://ddionrails.org/soeptools":soeptools} bundle. Please inform the author about issues using this {browse "https://github.com/ddionrails/soeptools/issues":tracker}.
{p_end}

{pstd}
The source code of the program is licensed under the GNU General Public License version 3 or later. The corresponding license text can be found on the internet at {browse "http://www.gnu.org/licenses/"} or in {help gnugpl}.
{p_end}


{marker author}{...}
{title:Authors}

{pstd}
Knut Wenzig ({browse "mailto:kwenzig@diw.de":kwenzig@diw.de}), DIW Berlin, German Socio-Economic Panel (SOEP), Germany.
{p_end}

