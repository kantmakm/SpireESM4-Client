<cfcomponent name="product Loader" extends="resources.page">
	<cffunction name="preObjectLoad">
		<cfset var lcl = structnew()>
		<cfsetting requesttimeout="6000">
		<!--- 
			grape items can come over either as "merlot", "merlot,pinot noir", or "merlot(44%),pinot noir(66%)" 
			this page 
				- queries the grapes,
				- breaks them into a temp table (aj_loading_grapes)
				- and uses that to do set based queries for insertion and update.
		--->
		
		<!--- determine latest load to query latest data --->
		<cfquery name="lcl.latestload" datasource="#requestObject.getVar("dsn")#">
			SELECT top 1 loadid, loadts
			FROM aj_loading 
			ORDER BY loadts	
		</cfquery>
		
		<cfif lcl.latestload.recordcount NEQ 1>
			<cfthrow message="latest load not findeable">
		</cfif>
		
		<cfset lcl.latestloadid = lcl.latestload.loadid>
		
		<!--- clear it --->
		<cfquery name="lcl.cleartemp" datasource="#requestObject.getVar("dsn")#">
			DELETE FROM aj_loading_grapes
		</cfquery>
		
		<!--- get them --->
		<cfquery name="lcl.grapelists" datasource="#requestObject.getVar("dsn")#">
			SELECT  ajl.grape, item_number
			FROM aj_loading ajl
			WHERE  ajl.loadid = <cfqueryparam value="#lcl.latestloadid#" cfsqltype="cf_sql_varchar">
				AND ajl.grape <> 'na' 
				AND ajl.grape <> '' 
				AND ajl.grape is not null
		</cfquery>
		
		<cfloop query="lcl.grapelists">
			<cfset lcl.grapetxt = replace(lcl.grapelists.grape, "/", ",", "all")>
			<cfset lcl.grapetxt = rereplace(lcl.grapetxt, "[\(\)\%0-9]","","all")>	
			<cfset lcl.item_number = lcl.grapelists.item_number>
			<cfloop list="#lcl.grapetxt#" index="lcl.listitm" delimiters=",/">
				<cfset lcl.itm = trim(lcl.listitm)>
				<cfset lcl.itm = rereplace(lcl.itm, "[:space:]+", " ", "all")>
				<cfset lcl.itm = rereplace(lcl.itm, "^[^a-zA-Z0-9]", "")>
				<cfset lcl.itm = rereplace(lcl.itm, "[^a-zA-Z0-9]$", "")>
				<cfset lcl.itm = ucase(mid(lcl.itm,1,1)) & lcase(mid(lcl.itm, 2,len(lcl.itm)))>
				<cfset lcl.safeitm = rereplace(lcl.itm, "[^a-z0-9A-Z]", "_","all")>
				<cfset lcl.safeitm = rereplace(lcl.safeitm, "[_]+", "_","all")>

				<cfquery name="lcl.addtoloadinggrape" datasource="#requestObject.getVar("dsn")#">
					INSERT INTO aj_loading_grapes (
						grape, safegrape, item_number
					) VALUES (
						'#trim(lcl.itm)#',
						'#trim(lcl.safeitm)#',
						'#trim(lcl.item_number)#'
					)
				</cfquery>
			</cfloop>
		</cfloop>
		
		<!--- determine items that do not already have corresponding names and add them as taxonomy items --->
		<cfquery name="lcl.notax" datasource="#requestObject.getVar("dsn")#">
			SELECT distinct ajlg.grape, ajlg.safegrape
			FROM aj_loading_grapes ajlg
			LEFT OUTER JOIN taxonomyitems ti ON ajlg.safegrape = ti.safename AND ti.taxonomyid = 'grape'
			WHERE ti.id is null
		</cfquery>
	
		<!--- using above q, add to aj_loading_grapes --->
		<cfloop query="lcl.notax">
			<cfquery name="insertba" datasource="#requestObject.getVar("dsn")#">
				INSERT INTO taxonomyitems (id,name,safename,description, changedby,deleted,created,modified,taxonomyid,sortkey) 
				VALUES (
					<cfqueryparam value="#createuuid()#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#lcl.notax.grape#" cfsqltype="cf_sql_varchar" maxlength="50">,
					<cfqueryparam value="#lcl.notax.safegrape#" cfsqltype="cf_sql_varchar" maxlength="50">,
					<cfqueryparam value="#lcl.notax.grape#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="8C8DD7E6-EA08-57D6-6556D3BB74048D54" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_timestamp">,
					<cfqueryparam value="grape" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#currentrow#" cfsqltype="cf_sql_varchar">					
				)
			</cfquery>
		</cfloop>
		
		<!--- 
			This query clears out taxonomy relations that are related to products for reinsertion 
			- maybe refactor to udpate and insert
		 --->
		 
		<cfquery name="deleteproducttaxrels" datasource="#requestObject.getVar("dsn")#" result="m">
			DELETE tr	
			FROM  taxonomyrelations tr
			INNER JOIN aj_loading ON 
				relationid = aj_loading.item_number 
				AND aj_loading.loadid = <cfqueryparam value="#lcl.latestloadid#" cfsqltype="cf_sql_varchar">
			INNER JOIN taxonomyItems ti ON tr.taxonomyItemId = ti.id
			WHERE 
				tr.relationtype = 'products'
				AND ti.taxonomyid = <cfqueryparam value="grape" cfsqltype="cf_sql_varchar">
				AND tr.siteid = 'AD1724FF-E347-83EA-18FD424840AD5849'
		</cfquery>
	
		<!--- 
			This query reinserts taxonomy relations that are related to products 
			- maybe refactor with above q to udpate and insert 
		--->
		 
		<cfquery name="reinsertproducttaxrels" datasource="#requestObject.getVar("dsn")#">
			INSERT INTO taxonomyrelations (taxonomyitemid, relationtype, relationid, siteid)
			SELECT 
				ti.id,
				'products',
				ajlg.item_number,
				'AD1724FF-E347-83EA-18FD424840AD5849'	
			FROM aj_loading_grapes ajlg
			INNER JOIN taxonomyitems ti ON 
				ti.taxonomyid = <cfqueryparam value="grape" cfsqltype="cf_sql_varchar">
				AND ti.safename = ajlg.safegrape
		</cfquery>
		
		<cfabort>
	</cffunction>
</cfcomponent>
