<cfcomponent name="taxonomies" extends="resources.abstractmodel" output="false">

	<cffunction name="init" output="false">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<!--- <cfset startorm("cartitems")> --->
		<cfreturn this>
	</cffunction>
	  
	<cffunction name="taxonomyMenu">
		<cfargument name="menuid">
		<cfargument name="menuitemid">
		<cfset var lcl = structnew()>
		
		<cfif NOT (structkeyexists(arguments,"menuid") OR structkeyexists(arguments,"menuitemid"))>
			<cfthrow message="menuid or menuitemid should be defined">
		</cfif>
		
		<cfquery name="lcl.q" datasource="#requestObject.getVar("dsn")#" cachedwithin="#iif(requestObject.isFormUrlVarSet("refresh"), 0, "createtimespan(0,1,0,0)")#">
			SELECT 
				t.id taxonomyid, t.name taxonomyname, 
				tmi.id taxonomymenuitemid,
				ti.name taxonomyitemname, ti.id taxonomyitemid, ti.sortkey, ti.safename
			FROM taxonomyMenuItems tmi 
			INNER JOIN taxonomyMenus tm ON tmi.taxonomymenuid = tm.id
			INNER JOIN taxonomyItems ti ON tmi.taxonomyId = ti.taxonomyid 
			INNER JOIN taxonomy t ON ti.taxonomyid = t.id
			INNER JOIN taxonomyRelations tr ON ti.id = tr.taxonomyItemid
			INNER JOIN taxonomyRelations tr2 ON tr.relationid = tr2.relationid AND tr2.taxonomyItemId = tm.baseTaxonomyItemId
			WHERE 
				<cfif structkeyexists(arguments,"menuid")>
					tmi.taxonomyMenuId = <cfqueryparam value="#arguments.menuid#" cfsqltype="cf_sql_varchar">
				<cfelse>
					tmi.id = <cfqueryparam value="#arguments.menuitemid#" cfsqltype="cf_sql_varchar">
				</cfif>
			GROUP BY
				t.id,
				t.name,
				tmi.id,
				ti.name, 
				ti.id,
				ti.sortkey,
				ti.safename,
				tmi.id, 
				tmi.sortorder
		</cfquery>
		
		<cfquery name="lcl.q2" datasource="#requestObject.getVar("dsn")#" cachedwithin="#iif(requestObject.isFormUrlVarSet("refresh"), 0, "createtimespan(0,1,0,0)")#">
			SELECT 
				tmf.taxonomyItemId, tmi.id
			FROM taxonomyMenuItems tmi 
			INNER JOIN taxonomyMenuFavorites tmf ON tmi.id = tmf.taxonomyMenuItemid
			WHERE 
				<cfif structkeyexists(arguments,"menuid")>
					tmi.taxonomyMenuId = <cfqueryparam value="#arguments.menuid#" cfsqltype="cf_sql_varchar">
				<cfelse>
					tmi.id = <cfqueryparam value="#arguments.menuitemid#" cfsqltype="cf_sql_varchar">
				</cfif>
		</cfquery>
		
		<cfset lcl.q2s = structnew()>
		<cfloop query="lcl.q2">
			<cfset lcl.q2s[taxonomyItemId] = 1>
		</cfloop>
		
		<cfset lcl.na = arraynew(1)>
		<cfloop query="lcl.q">
			<cfset arrayappend(lcl.na, IIF(structkeyexists(lcl.q2s, taxonomyitemid),1,0))>
		</cfloop>
		
		<cfset queryaddcolumn(lcl.q, "favorite", lcl.na)>

		<cfif structkeyexists(arguments,"menuitemid")>
			<cfquery dbtype="query" name="lcl.q">
				SELECT * FROM lcl.q WHERE favorite = 0
			</cfquery>
		</cfif>

		<cfreturn lcl.q>
	</cffunction>
	
	<cffunction name="loadById" output="false">
		<cfargument name="id" required="true">
		
		<cfset var q = "">
		<cfset var r = structnew()>
		<cfset var t = structnew()>
		
		<cfquery name="q" datasource="#requestObject.getVar("dsn")#">
			SELECT t.name txname, t.id tid, 
					ti.name tiname, ti.description tidescription, ti.id tiid, ti.safename tisafename
			FROM taxonomyRelations tr 
			INNER JOIN taxonomyItems ti ON tr.taxonomyItemId = ti.id 
			INNER JOIN taxonomy t ON ti.taxonomyId = t.id WHERE tr.relationId = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
			ORDER BY t.name, ti.name 
		</cfquery>
		
		<cfoutput query="q" group="tid">
			<cfif NOT structkeyexists(r, tid)>
				<cfset r[tid] = arraynew(1)>
			</cfif>
			<cfoutput>
				<cfset t = structnew()>
				<cfset t.name = tiname>
				<cfset t.tid = tiid>
                <cfset t.safename = tisafename>
				<cfset arrayappend(r[tid], t)>
			</cfoutput>
		</cfoutput>

		<cfset variables.loadedtaxonomy = r>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="hastermid" output="false">
		<cfargument name="tid" required="true">
		<cfreturn isdefined("variables.loadedtaxonomy") AND structkeyexists(variables.loadedtaxonomy, arguments.tid)>
	</cffunction>
	
	<cffunction name="getTermItems" output="false">
		<cfargument name="tid" required="true">
		
		<cfif not hastermid(arguments.tid)>	
			<cfreturn arraynew(1)>
		</cfif>
		
		<cfreturn variables.loadedtaxonomy[arguments.tid]>
	</cffunction>
	
    <cffunction name="getFirstTermItemSafeName" output="false">
		<cfargument name="tid" required="true">
		
		<cfif not (hastermid(arguments.tid) AND arraylen(variables.loadedtaxonomy[tid]))>	
			<cfreturn "">
		</cfif>
		<cfreturn variables.loadedtaxonomy[arguments.tid][1]['safename']>
	</cffunction>
    
	<cffunction name="getFirstTermItemName" output="false">
		<cfargument name="tid" required="true">
		
		<cfif not (hastermid(arguments.tid) AND arraylen(variables.loadedtaxonomy[tid]))>	
			<cfreturn "">
		</cfif>
		<cfreturn variables.loadedtaxonomy[arguments.tid][1]['name']>
	</cffunction>
	
	<cffunction name="dump" output="false">
    	<cfdump var="#variables.loadedtaxonomy#">
        <cfabort>
	</cffunction>
</cfcomponent>