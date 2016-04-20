{smcl}
{* *! version 0.3 20 April 2016}{...}
help for {cmd:soepidvars}{right:version 0.3  (20 April 2016)}
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

