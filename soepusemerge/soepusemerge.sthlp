{smcl}
{* *! version 0.1 13 April 2016}{...}
help for {cmd:soepusemerge}{right:version 0.1  (13 April 2016)}
{hline}


{title:Title}

{phang}
{bf:soepusemerge} {hline 2} Open a template file and integrate variables from related files.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepusemerge} {help filename:{it:filename}} {cmd:using} {it:pathname}, {opt clear} [{opt keyvars(varlist)}  {opt verbose}]
{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:soepusemerge} opens dataset {help filename:{it:filename}} and merges variables from all related datasets in {it:pathname}, performing a merge 1:1 with key variables specified in the option {opt keyvars} while requiring a complete match with assert(match) and merging only variables without missings. Option {opt verbose} produces much more output.
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

