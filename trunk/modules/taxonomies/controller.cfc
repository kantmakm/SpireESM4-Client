<cfcomponent extends="resources.abstractController" ouput="false">
	
	<cffunction name="menu">
		<cfset variables.taxonomiesModel = this.getTaxonomiesModel("taxonomies")>
		<cfset variables.taxonomylist = variables.taxonomiesModel.taxonomyMenu(menuid = variables.data.menuid)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="moremenu">
		<cfset variables.taxonomiesModel = this.getTaxonomiesModel("taxonomies")>
		<cfset variables.taxonomylist = variables.taxonomiesModel.taxonomyMenu(menuitemid = variables.data.menuitemid)>
		<cfreturn this>
	</cffunction>

	<cffunction name="allmenu">
		<cfset variables.taxonomiesModel = this.getTaxonomiesModel("taxonomies")>
		<cfset variables.taxonomylist = variables.taxonomiesModel.taxonomyMenu(menuitemid = variables.data.menuitemid)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="category">
		<cfset variables.taxonomiesModel = this.getTaxonomiesModel("taxonomies")>
		<cfset variables.taxonomylist = variables.taxonomiesModel.taxonomyMenu(menuitemid = variables.data.menuitemid)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="searchcatagory">
		<cfset variables.taxonomiesModel = this.getTaxonomiesModel("taxonomies")>
		<cfset variables.taxonomylist = variables.taxonomiesModel.taxonomyMenu(menuitemid = variables.data.menuitemid)>
		<cfreturn this>
	</cffunction>		
	
</cfcomponent>