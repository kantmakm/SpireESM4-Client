<cfcomponent name="Scan folder View" extends="resources.page">
	<cffunction name="preobjectLoad">
		<!--- This function scans the ui/productimages dir and moves the files into likenamed directories and moves them in after cleaning out exising ones --->
		<cfset var lcl = structnew()>

		<cfset lcl.folder = requestObject.getVar("machineroot") & "/ui/productimages/">
		<cfdirectory action="list" directory="#lcl.folder#" type="all" name="lcl.dir">
		
		<cfloop query="lcl.dir">
			<cfif lcl.dir.type EQ "file">
				<cfset lcl.thisdir = lcl.dir.directory & "/" & listdeleteat(name, listlen(name,"."),".")>
				<cfif NOT directoryexists(lcl.thisdir)>
					<cfdirectory action="create" directory="#lcl.thisdir#">
				<cfelse>
					<cfdirectory action="list" directory="#lcl.thisdir#" type="all" name="lcl.indir">
					<cfloop query="lcl.indir">
						<cfif lcl.indir.type EQ "file">
							<cffile action="delete" file="#lcl.indir.directory#/#name#">
						</cfif>
					</cfloop>
				</cfif>
				
				<cffile action="move" source="#lcl.folder##lcl.dir.name#" destination="#lcl.thisdir#/#lcl.dir.name#">
			</cfif>
		</cfloop>

		<cfabort>
	</cffunction>
</cfcomponent>