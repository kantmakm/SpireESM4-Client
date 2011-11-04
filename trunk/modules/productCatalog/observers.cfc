<cfcomponent name="ordersobservers" extends="resources.abstractobserver" output="false">
	
	<cffunction name="search_synchsearchables" output="false">
		<cfargument name="observed" required="true">
	
		<cfset var lcl = structnew()>
		<cfset var indexable = "">
	
		<!--- this set of queries gets all the deleted products and sets them to be deleted on the next indexsome operation --->
		<cfquery name="lcl.products" datasource="#variables.requestObject.getVar('dsn')#" result="m">
			UPDATE i SET i.deleted = 1
			FROM products p
			INNER JOIN indexables i ON p.id = i.objid
			WHERE p.deleted = 1
		</cfquery>
	
		<!--- this query gets all the products and related taxonomies --->
		<cfquery name="lcl.products" datasource="#variables.requestObject.getVar('dsn')#" result="m">
			SELECT  p.id, p.title, p.description, p.urlname, t.id taxid, ti.name, ti.safename, ti.id, ti.taxonomyid
			FROM products p
			LEFT OUTER JOIN taxonomyRelations tr ON p.id = tr.relationid
			LEFT OUTER JOIN taxonomyItems ti ON tr.taxonomyitemid = ti.id
			LEFT OUTER JOIN taxonomy t ON ti.taxonomyid = t.id
			WHERE p.siteid = <cfqueryparam value="#variables.requestObject.getVar('siteid')#" cfsqltype="cf_sql_varchar">
				AND p.urlname NOT like 'other%'
				AND p.deleted = 0
			ORDER BY p.id, t.id, ti.taxonomyid
		</cfquery>

		<cfset lcl.indexable = observed.newIndexable()>
		
		<!--- this looped query aggregates all the taxonomies into a structure and updates the indexable with it for later use --->
        <cfoutput query="lcl.products" group="id">
			<cfset lcl.tags = structnew()>
			
			<cfoutput>
				<cfif NOT structkeyexists(lcl.tags, taxid)>
					<cfset lcl.tags[taxid] = arraynew(1)>
				</cfif>
	        	<cfset arrayappend(lcl.tags[taxid], safename)>
	        	<cfif lcl.products.taxonomyid EQ "product_categories">
	        		<cfset lcl.productcat = lcl.products.safename>
	        	</cfif>
			</cfoutput>
			
			<cfif lcl.productcat NEQ "other">
				<cfset lcl.indexable.clear()>
	            <cfset lcl.indexable.setObjId(lcl.products.id)>
				<cfset lcl.indexable.setPath(replace(lcl.productcat,"_","-","all") & "/product/" & lcl.products.urlname & "/")>
	            <cfset lcl.indexable.setTitle(lcl.products.title)>
	            <cfset lcl.indexable.setDescription(lcl.products.description)>
				<cfset lcl.indexable.setTagsJSON(serializejson(lcl.tags))>
				<cfset lcl.indexable.setType("page")>
				<cfset lcl.indexable.setViewcfc("modules.productcatalog.searchview")>
	            <cfset lcl.indexable.save()>
			</cfif>
       	</cfoutput>

		<cfreturn observed>
	</cffunction>
	
</cfcomponent>