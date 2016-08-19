{smcl}
{* *! version 0.10 (20160808)}{...}
help for {cmd:soepapplyvaluelabel}{right:version 0.10 (20160808)}
{hline}


{title:Title}

{phang}
{bf:soepapplyvaluelabel} {hline 2} Applies value label from templates to variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepapplyvaluelabel} {help varlist:{it:varlist}} {cmd:using} {it:pathname}, {opt id(template ids)} [{opt language(code)}]{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt id(template ids)}}one ore more (comma separated) ids from the templates list, example: id(1,5){p_end}
{synopt:{opt language(code)}}suffix to column {it:label} in metadata, example: language(de) uses column label_de{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:soepapplyvaluelabel} uses value templates from a file {it:values_templates.csv} {it:pathname}. The value label pairs found there are applied to the variables in {it:varlist}. The name of the value label will be t1_5 if {opt id(1,5)} is specified.
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

