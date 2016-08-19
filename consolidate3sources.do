

local consolidated "//hume/rdc-gen/consolidated/soep-core/soep.v31_test/"
local partial "\\hume\rdc-gen\generations\soep-core\soep.v31_test\partial"
local complete "//hume/rdc-gen/consolidated/soep-core/soep.v31_test/"
local targetpath "\\hume\rdc-gen\generations\soep-core\soep.v31_test\preliminary"

* local partials: alle partials_blabla.dta, für die es ein update gibt

local partialnames : dir "`partial'" files "*_*.dta"
display `"`partials'"'
foreach partial of local partialnames {
	display `"`partial'"'
	gettoken addroot rest : partial, parse("_") quotes
    display "`addroot'"
	local root = "`root' `addroot'"
	}
display "root: `root'"
*local test : subinstr local root "`firstroot`" "", all word

local number : word count `root'
display "number: `number'"

while `number' > 0 {
	local firstroot : word 1 of `root'
	display "firstroot:`firstroot'"
	local partials = `"`partials' `firstroot'"'
	display "partial:`partials'"
	local root : subinstr local root "`firstroot'" "", all word
	display "root:`root':"
	local number : word count `root'
	display "number: `number'"
}
display "partials:`partials'"

* local consolidateds: alle files in consolidated
local consolidateds : dir "`consolidated'" files "*.dta"
local consolidateds : subinstr local consolidateds ".dta" "", all
local consolidateds : subinstr local consolidateds `"""' "", all
display `"`consolidateds'"'

* local complete: alle files in complete
local completes : dir "`complete'" files "*.dta"
local completes : subinstr local completes ".dta" "", all
local completes : subinstr local completes `"""' "", all
display `"`completes'"'

local allfiles = `"`completes' `partials' `consolidateds'"'
display `"`allfiles'"'
	
local number : word count `allfiles'
display "number: `number'"

while `number' > 0 {
	local file : word 1 of `allfiles'
	local filestatus "consolidated"
	foreach check of local partials {
		if "`check'" == "`file'" local filestatus "partial"
	}
	foreach check of local completes {
		if "`check'" == "`file'" local filestatus "complete"
	}
	if "`filestatus'" == "complete" {
		display "`file' is complete: copy from complete"
	}
	if "`filestatus'" == "partial" {
		display "`file' is partial: merge with related files"
	}
	if "`filestatus'" == "consolidated" {
		display "`file' is only in consolidated: copy from consolidated"
	}
	local allfiles : subinstr local allfiles "`file'" "", all word
	local number : word count `allfiles'
}
