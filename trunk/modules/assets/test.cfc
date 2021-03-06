<cfcomponent displayname="MyCFCTest" extends="mxunit.framework.TestCase">
		
	<cffunction name="setUp" returntype="void" access="public">		
		<cfset var lcl = structNew()>
		
		<cfset variables.unittestname = "Unit Test Asset">
		<cfset this.unittestsearchterm = "unittesting.docx">
		<cfset variables.assetgroupid = createuuid()>
		<cfset variables.assetid = createuuid()>
		<cfset variables.requestObject = request.requestObject>
    		<cfset loadController()>
		
		<cfquery name="lcl.qry" datasource="#variables.requestObject.getVar('dsn')#">
			SELECT id FROM users
			WHERE username = 'sa@spiremedia.com'
		</cfquery>
		
		<cfset lcl.userid = lcl.qry.id>
		
		<!--- insert assetgroup, asset --->
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			INSERT INTO assetGroups (id,name,modified,deleted,description)
			VALUES (
				<cfqueryparam value="#variables.assetgroupid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="Asset Group - Unit Test" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#CreateODBCdate(Now())#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="Asset Group - Unit Test" cfsqltype="cf_sql_varchar">
			)
		</cfquery>
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			INSERT INTO assets (id,name,filename,changeddate,changedby,assetgroupid,active,deleted,filesize)
			VALUES (
				<cfqueryparam value="#variables.assetid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="unittesting.docx" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#CreateODBCdate(Now())#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#lcl.userid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.assetgroupid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="1" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="0" cfsqltype="cf_sql_bit">,
				<cfqueryparam value="1000" cfsqltype="cf_sql_integer">
			)
		</cfquery>
		<cfdirectory action="create" directory="#requestObject.getVar("cmsmachineroot")#docs/assets/#variables.assetid#">
		<cffile action="copy" source="#requestObject.getVar("cmsmachineroot")#docs/assets/unittest.docx" destination="#requestObject.getVar("cmsmachineroot")#docs/assets/#variables.assetid#/unittesting.docx">
	</cffunction>
    
    <cffunction name="teardown" returntype="void" access="public">
		<!--- remove test assetgroup, asset --->
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			DELETE FROM assets WHERE id = <cfqueryparam value="#variables.assetid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			DELETE FROM assetGroups WHERE id = <cfqueryparam value="#variables.assetgroupid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cftry>
			<cffile action="delete" file="#requestObject.getVar("cmsmachineroot")#docs/assets/#variables.assetid#/unittesting.docx">
			<cfdirectory action="delete" directory="#requestObject.getVar("cmsmachineroot")#docs/assets/#variables.assetid#/">
			<cfcatch>mwhouiin</cfcatch>
		</cftry>
	</cffunction>
    
    <cffunction name="loadController" access="private">
    	<cfargument name="data" default="#structnew()#">
    	<cfargument name="requestObject" default="#variables.requestObject#">
    	<cfargument name="pageref" default="#structnew()#">
    	<cfset variables.controller = createObject("component","modules.assets.controller").init(
			data=arguments.data,
			requestObject=arguments.requestObject,
			pageref=arguments.pageref
		)>
    </cffunction>
    
    <cffunction name="InterfaceTest">
    	<cfset var itm = variables.controller.getModel(requestObject=variables.requestObject)>
        <cfset var count = "">
        <cfset var data = structnew()>
        <cfset var html = "">
        <cfset var aggregator = "">
		
		<!--- model tests --->
		<cfset count = itm.getAsset( id = variables.assetid ).recordcount>
        <cfset assertequals(expected=1,actual=count,message="did not find correct asset")>
		
		<cfset count = itm.getAssetGroup( assetgroupid = variables.assetgroupid ).recordcount>
        <cfset assertequals(expected=1,actual=count,message="did not find correct asset group")>

		<cfset count = itm.getAllAssets().recordcount>
        <cfset assertNotEquals(expected=0,actual=count,message="did not find any assets")>

		<!--- ctrlr tests --->
		<!--- assets --->
		<cfset data.assetids = variables.assetid> 
    	<cfset loadController(data = data)>
		<cfset html = variables.controller.showHTML()>
        <cfset asserttrue(condition = find('<div class="supportingData  doc_',html), message="did not &lt;div class=""supportingData  doc_")>
        <cfset asserttrue(condition = refind('<a href\="\/docs\/assets\/[a-zA-Z0-9\-]{35}/.*Unit Test Asset</a>',html),message="did not find matching link")>

		<!--- asset groups --->
		<cfset data.assetgroupid = variables.assetgroupid> 
    	<cfset loadController(data = data)>
		<cfset html = variables.controller.showHTML()>
        
        <cfset asserttrue(condition = find('<div class="supportingData  doc_',html), message="did not &lt;div class=""supportingData  doc_")>
        <cfset asserttrue(condition = refind('<a href\="\/docs\/assets\/[a-zA-Z0-9\-]{35}/.*Unit Test Asset</a>',html),message="did not find matching link")>

		<!--- testGetPagesforSiteSearch --->
        <cfset aggregator = createobject('component','modules.search.searchableaggregator').init(requestObject=variables.requestObject)>
		<cftry>
        	<cfset variables.controller.getPagesforSiteSearch( aggregator = aggregator)>
            <cfcatch>
            	<cfset fail("asset search indexing fails : #cfcatch.message#")>
            </cfcatch>
        </cftry>
    </cffunction> 
   
</cfcomponent>