{smcl}
{* *! version 0.15 29 September 2016}{...}
help for {cmd:soepgenpre}{right:version 0.15  (29 September 2016}
{hline}


{title:Title}

{phang}
{bf:soepgenpre} {hline 2} Consolidate files from three sources (consolidated, partial, complete)


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:soepgenpre}, {opt version(string)} [{opt humepath(string)} {opt verbose} {opt empty} {opt dopartial} {opt docomplete} {opt replace}]
{p_end}

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt version(version)}}SOEP version, e.g. version(v31). This information is used to construct pathnames like //hume/rdc-gen/generations/soep-core/soep.v31/partial{p_end}
{synopt:{opt humepath(string)}}which string has to preced /rdc-gen/ in order to get a valid path. Default for windows computers and a special linux computer within the SOEP are included.{p_end}
{synopt:{opt docomplete}}do not copy from consolidated, merge partial files only if {opt dopartial} is specified{p_end}
{synopt:{opt dopartial}}do not copy from consolidated, copy complete files only if {opt docomplete} is specified{p_end}
{synopt:{opt rsync}}use rsync (as shell command) instead of copy (from complete and consolidated){p_end}
{synopt:{opt empty}}empty pre-folder{p_end}
{synopt:{opt replace}}replace when copying or saving{p_end}
{synopt:{opt verbose}}display a lot of output{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{cmd:soepgenpre} is tailored for SOEP's internal system of folders and files. It is using defaults which make only sense within DIW Berlin. It looks for dta-files in three folders (complete, partial, consolidated).

{pstd}
1. If a file found in complete, this file will be copied to the pre-folder.

{pstd}
2. For all dta-files found in partial, all of root filenames will be processed with {help soepusemerge:{it:soepusemerge}}, if not already processed in step 1. The result will be saved to the pre-folder. An Excel file partialresults.xls in the pre-folder shows the executed operations.

{pstd}
3. If a dta-file can be exclusively found in consolidated (and this name is not a root file name in step 2), this file will be coppied to the pre-folder.

{pstd}
The relevant folders are:

{pstd}
consolidated: folder where to result of the previous year and the consolidated new data are stored. Typical names: bepgen.dta, beh.dta

{pstd}
partial: folder where the new generated variables are stored, which have to be merged to datasets in colsolidated. Typical name: bepgen_jdoe.dta

{pstd}
complete: folder where complete generated datasets are stored, which are completely new or are a complete update for datasets in consolidated

{pstd}
pre: folder where the result of this procedure, i.e. the preliminary files, is stored.

{pstd}
If version is "v31" and humepath is "//hume/" the adresses are:

{pstd}
consolidated: "//hume/rdc-gen/consolidated/soep-core/soep.v31/"

{pstd}
partial: "//hume/rdc-gen/generations/soep-core/soep.v31/partial/"

{pstd}
complete: partial: "//hume/rdc-gen/generations/soep-core/soep.v31/complete/"

{pstd}
pre: "//hume/rdc-gen/generations/soep-core/soep.v31/pre/"


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

