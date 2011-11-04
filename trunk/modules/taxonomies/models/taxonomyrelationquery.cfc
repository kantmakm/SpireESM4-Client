<cfcomponent name="taxonomyrelationquery" extends="resources.abstractmodel" output="false">

	<cffunction name="init" output="false">
		<cfargument name="requestObject" required="true">
		
		<cfset variables.requestObject = arguments.requestObject>
		<cfset variables.relateto = "">
		<cfset variables.relatetofields = "p.title">
		<cfset variables.filters = structnew()>
		<cfset variables.typerelation = structnew()>
		<cfset variables.sort = "p.title">
		<cfset variables.addtljoins = structnew()>
		<cfset variables.more = arraynew(1)>
				
		<cfreturn this>
	</cffunction>
	
	<cffunction name="addTaxonomyTypeFilter">
		<cfargument name="typeid">
		<cfargument name="typevalue">
		
		<cfif NOT structkeyexists(variables.typerelation, typeid)>
			<cfset variables.filters[typeid] = typevalue>
		</cfif>
	</cffunction>
	
	<cffunction name="addTaxonomyTypeRelation">
		<cfargument name="typeid">
		<cfif NOT structkeyexists(variables.filters, typeid)>
			<cfset variables.typerelation[typeid] = 1>
		</cfif>
	</cffunction>
	
	<cffunction name="setRelation">
		<cfargument name="relation">
		<cfset variables.relateto = relation>
	</cffunction>
	
	<cffunction name="setJoin">
		<cfargument name="table" required="true">
		<cfargument name="crit" required="true">
		<cfset variables.addtljoins[table] = crit>
	</cffunction>
	
	<cffunction name="setSort">
		<cfargument name="crit" required="true">
		<cfset variables.sort = crit>
	</cffunction>
	
	<cffunction name="setMore">
		<cfargument name="name" required="true">
		<cfargument name="val" required="true">
		<cfset lcl = structnew()>
		<cfset lcl.name = name>
		<cfset lcl.value = val>
		<cfset arrayappend(variables.more, lcl)>
	</cffunction>
	
	<cffunction name="run">
		<cfargument name="more" default="#structnew()#">
		<cfset var item = "">
		<cfset var lcl = structnew()>
		
		<cfset lcl.qs = arraynew(1)>
		<cfset lcl.mqh = "">
		
		<cfif structkeyexists(more, "from")>
			<cfset lcl.h = structnew()>
			<cfset lcl.h.h = "SELECT COUNT(*) cnt">
			<cfset lcl.h.f = "">
			<cfset arrayappend(lcl.qs,lcl.h)>
			
			<cfset lcl.h = structnew()>
			<cfset lcl.h.h = "SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY #variables.sort#) AS row, p.id, #variables.relatetofields#">
			<cfset lcl.h.f = ") AS records WHERE row >= #more.from# AND row <= #more.to# ORDER BY row">
			<cfset arrayappend(lcl.qs, lcl.h)>
		<cfelse>
			<cfset lcl.h = structnew()>
			<cfset lcl.h.h = "SELECT p.id, #variables.relatetofields#">
			<cfset lcl.h.f = "ORDER BY #variables.sort#">
			<cfset arrayappend(lcl.qs, lcl.h)>
		</cfif>
		
		<cfloop array="#lcl.qs#" index="lcl.qq">
		
			<cfquery name="lcl.q" datasource="#requestObject.getVar("dsn")#">
				#lcl.qq.h# #lcl.mqh#
				FROM #variables.relateto# p
				<cfloop collection="#filters#" item="item">
				INNER JOIN taxonomyRelations #item#_tr ON #item#_tr.relationId = p.id
					<cfif variables.relateto eq 'products'>AND #item#_tr.relationType = 'products'</cfif><!--- 10/10/11: added to avoid duplicates --->
				INNER JOIN taxonomyItems #item#_ti ON 
					#item#_tr.taxonomyItemId = #item#_ti.id 
					AND #item#_ti.taxonomyid = <cfqueryparam value="#item#" cfsqltype="cf_sql_varchar">
					AND #item#_ti.safename IN (<cfqueryparam value="#filters[item]#" list="true" cfsqltype="cf_sql_varchar">)
				</cfloop>
				
				<cfloop collection="#typerelation#" item="item">
				INNER JOIN taxonomyRelations #item#_tr ON #item#_tr.relationId = p.id
					<cfif variables.relateto eq 'products'>AND #item#_tr.relationType = 'products'</cfif><!--- 10/10/11: added to avoid duplicates --->
				INNER JOIN taxonomyItems #item#_ti ON 
					#item#_tr.taxonomyItemId = #item#_ti.id 
					AND #item#_ti.taxonomyid = <cfqueryparam value="#item#" cfsqltype="cf_sql_varchar">
				</cfloop>
				
				<cfloop collection="#variables.addtljoins#" item="item">
					<cfset lcl.mitem = variables.addtljoins[item]>
					INNER JOIN #item# ON #preservesinglequotes(lcl.mitem)#
				</cfloop>
				<cfif arraylen(variables.more)>
					WHERE 1 = 1
					<cfloop array="#variables.more#" index="lcl.more">
						AND #lcl.more.name# = <cfqueryparam value="#lcl.more.value#">
					</cfloop>
				</cfif>
				#lcl.qq.f#
			</cfquery>
			<cfif isdefined("lcl.q.cnt")>
				<cfset lcl.mqh = ", #lcl.q.cnt# rcnt">
			</cfif>
		</cfloop>
	
		<cfreturn lcl.q>
	</cffunction>
	
</cfcomponent>
<!--- 
SELECT p.id, p.title 
FROM products p 
INNER JOIN taxonomyRelations product_categories_tr.tr ON product_categories_tr.relationId = p.id 
INNER JOIN taxonomyItems product_categories_ti ON 
	product_categories_tr.taxonomyItemId = product_categories_ti.id 
	AND product_categories_ti.taxonomyid = (param 1) 
	AND product_categories_ti.safename = (param 2) 
ORDER BY p.title --->