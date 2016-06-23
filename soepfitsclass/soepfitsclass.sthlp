{smcl}
{* *! version 0.9 23 June 2016}{...}
help for {cmd:soepfitsclass}{right:version 0.9  (23 June 2016)}
{hline}


{title:Title}

{phang}
{bf:soepfitsclass} {hline 2} Checks whether a variable fits to a classification


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepfitsclass} varname [using/] , {opt id(numbers)} [{opt verbose force}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id(numbers)}}comma seperated list of template ids, e.g. id(407,408){p_end}
{synopt:{opt verbose}}display more output{p_end}
{synopt:{opt force}}continues even if variable does not fit the classifiation{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:soepfitsclass} checks whether a variable fits to a specificated list of value templates. Firstly the command checks whether all values this variable shows are covered by the template(s). Secondly it checks whether the assigned value label contains all values from the template(s). The value templates are stored here: https://gitlab.soep.de/kwenzig/additionalmetadata/blob/master/templates/values_templates.csv. You have to clone the repository and specifiy with using the folder, where stata can find it. The default is "D:/lokal/additionalmetadata/templates/".

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

