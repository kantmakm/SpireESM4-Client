<cfcomponent name="product Loader" extends="resources.page">
	<cffunction name="preObjectLoad">
		<cfset var lcl = structnew()>
		
		<cfset lcl.filename = requestObject.getVar("ajimportfulldatapath", requestObject.getVar("machineroot") & "/modules/applejackproductloader/data/applejack.txt")>
		<cfsetting requesttimeout="6000">
		<!--- load products into temp table --->
		<cfset var loadid = createuuid()>
		<cfset var loadts = now()>
		<cfset var more = structnew()>
		<!--- col 1 from extract doc  --->
		<cfset var columns = "Item_number,Normal_description,Vintage,Item_notes,Size_description,Long_description,Units_per_case,Unit_retail,Pack_retail,Units_per_pack,Warm_Case_retail,Quantity_on_hand,Most_recent_upc_code,Department_name,Group_name,Sub_department_name,Primary_vendor,Proof,Tax_flag,Unit_sale_retail,Case_sale_retail">
		<!--- col 2 from extract doc  --->
		<cfset columns = columns & replace(",Date sale starts,Date sale ends,Tasting_other notes,Country of origin,Region,Sub region1,Sub region2,Grape,Color,Classification,Wine Maker,Winery,Special rating,Parker rating,Other Rating,Featured Item,Web Address of product,Invoice Cost per Bottle,Sale Type Code,Pack Sale Price,Full Case Discount", " ", "_", "all")>
		<!--- col 3 from extract doc  --->
		<cfset columns = columns & replace(",Mixed Case Discount,Web selling Threshold,Web Groupings,Web unit Price,Web Pack price,Web Case Price,Web Unit Sale,Web Pack Sale,Web Case Sale,Web Sale Type,Web Sale Starting Date,Web Sale Ending Date,Number units on open POs,Points,Web Code,Available to Sell,Web Flags,Continent,Vineyard", " ", "_", "all")>
		<!--- col 4 from extract doc  --->
		<!---<cfloop from="62" to="80" index="idx">
			<cfset columns = listappend(columns, "r" & idx)>
		</cfloop>--->

		<!--- <cfset more.loadid = '10BA5D8E-E0B8-ABF4-77D076BA131330F6'><!--- 'loadid> ---> --->
		<cfset more.loadid = loadid>
		<cfset more.loadts = loadts>
<!---
<cfoutput>
<pre>
CREATE TABLE [dbo].[aj_loading](
	[id] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	<cfloop list="#columns#" index="field">
	,[#lcase(field)#] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL</cfloop>
) ON [PRIMARY]
</pre>
<cfabort>
</cfoutput>

--->

		<!---<cfhttp firstrowasheaders="false" url="#variables.requestObject.getVar("siteurl")#modules/applejackproductloader/data/applejack.txt" name="loadrecords" delimiter="#chr(9)#">--->
		<!---<cfset loadrecords = CSVToArray(lcl.filename,"",chr(9),true)/>
			<cfloop array="#loadrecords#" index="lcl.lineidx">
				<cfset l = structnew()>
				<cftry>
					<cfloop from="1" to="#arraylen(cols)#" index="i">
						<cfset l[cols[i]] = lcl.lineidx[i]>
					</cfloop>
					<cfset variables.process_load_item(l,more)>
					<cfcatch>
						<cfdump var=#lcl.lineidx#>
					</cfcatch>
				</cftry>
				
			</cfloop>
		--->

		
		<cfset cols = listtoarray(columns)>
		<!---
		<cfset row1 = arraynew(1)>
		<cfset row2 = arraynew(1)>
		<cfset row3 = arraynew(1)>
		
		<cfloop from="1" to="#arraylen(loadrecords[1])#" index="i">
			<cfset arrayappend(row1, loadrecords[1][i])>
			<cfset arrayappend(row2, loadrecords[2][i])>
			<cfset arrayappend(row3, loadrecords[3][i])>
		</cfloop>
		
		<table>
		<tr>
		<td valign="top"><cfdump var=#cols#></td>
		
		<td valign="top"><cfdump var=#row1#></td>
		<td valign="top"><cfdump var=#row2#></td>
		<td valign="top"><cfdump var=#row2#></td>
		</tr>
		</table>
		<cfabort>
--->

		
		<cfquery name="m" datasource="#requestObject.getVar("dsn")#">
			delete from aj_loading WHERE loadts < <cfqueryparam value="#dateadd("d",10, NOW())#" cfsqltype="cf_sql_date">
		</cfquery>
	
		<cfset lcl.myfile = FileOpen(lcl.filename, "read")>
		<cfloop condition="NOT FileIsEOF(lcl.myfile)">
			<cfset lcl.linea = FileReadLine(lcl.myfile)>
			<cfset lcl.lineb = replace(lcl.linea, chr(9), "-" & chr(9),"all")><!---for some reason, it was splitting on both space and nine so added a - to make sure split worked--->
			<cfset lcl.line = listtoarray(lcl.lineb,chr(9))>
	
			<cftry>
				<cfset lcl.l = structnew()>
				<cfloop from="1" to="#arraylen(cols)#" index="i">
					<cfset lcl.l[cols[i]] = trim(mid(lcl.line[i],1,len(lcl.line[i])-1))>
				</cfloop>
				<cfset variables.process_load_item(lcl.l,more)>
				<cfcatch>
				
					<pre><cfoutput>#lcl.linea#</cfoutput></pre>
					<br>
					<pre><cfoutput>#lcl.lineb#</cfoutput></pre>
					<cfdump var=#lcl.line#>
					<cfdump var=#cfcatch#>
					<cfabort>
				</cfcatch>
			</cftry>
		</cfloop>
		<cfset fileclose(lcl.myfile)>
	
	<!--- loop over records and insert into ajloading via process_load_item function
	<cfloop array="#loadrecords#" index="lcl.lineidx">
		<cfset l = structnew()>
		<cftry>
			<cfloop from="1" to="#arraylen(cols)#" index="i">
				<cfset l[cols[i]] = lcl.lineidx[i]>
			</cfloop>
			<cfset variables.process_load_item(l,more)>
			<cfcatch>
				<cfdump var=#lcl.lineidx#>
			</cfcatch>
		</cftry>
		
	</cfloop>
 --->
		<!--- the search feature stores the price of the item, update it to be reindex if any of the prices change. --->
		<!--- dev that never made it <cfquery name="m" datasource="#requestObject.getVar("dsn")#">
			UPDATE indexables
			SET 
				indexeables.reindex = 1
			FROM aj_loading
			INNER JOIN productPrices ON products.id = aj_loading.item_number AND aj_loading.loadid = '#more.loadid#'
			WHERE aj_loading.loadid = '#more.loadid#'
				AND aj_loading.item_number = indexables.objid
				AND productPrices.type = 'unit' 
				AND (	
					(aj_loading.unit_retail <> '' AND productPrices.price <> CAST(aj_loading.unit_retail AS decimal(10,2)))
					OR (aj_loading.unit_sale_retail <> '' AND productPrices.price_sale <> CAST(aj_loading.unit_sale_retail AS decimal(10,2)))
					OR (aj_loading.web_unit_sale <> '' AND productPrices.price_member <> CAST(aj_loading.web_unit_sale AS decimal(10,2)))
				}
		</cfquery>
		--->
 
		<!--- update existing products table --->
		<cfquery name="m" datasource="#requestObject.getVar("dsn")#">
			UPDATE products
			SET 
				products.name = aj_loading.normal_description,
				products.urlname = aj_loading.item_number + '-' + aj_loading.normal_description,
				products.description = aj_loading.long_description,
				products.sizeDescription = aj_loading.size_description,
				products.unitspercase = aj_loading.units_per_case,
				products.unitsperpack = aj_loading.units_per_pack,
				products.sub_region1	= aj_loading.sub_region1,
				products.sub_region2	= aj_loading.sub_region2,
				products.title = aj_loading.normal_description,
				products.availableunits = aj_loading.available_to_sell,
				products.deleted = 0,
				products.modified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
			FROM  products
			INNER JOIN aj_loading ON products.id = aj_loading.item_number AND aj_loading.loadid = '#more.loadid#'
		</cfquery>

		<!--- insert new products --->
		<cfquery name="m" datasource="#requestObject.getVar("dsn")#">
			INSERT INTO products (id,name,urlname,title, description, sizeDescription, unitsPerCase, unitsPerPack,
				sub_region1,sub_region2, availableunits, changedby, created, modified, siteid)
			SELECT 
				ajl.item_number id,
				ajl.normal_description name,
				ajl.item_number + '-' + ajl.normal_description urlname,
				ajl.normal_description title,
				ajl.long_description description,
				ajl.size_description sizedescription,
				ajl.units_per_case unitspercase,
				ajl.units_per_pack unitsperpack,
				ajl.sub_region1 sub_region1,
				ajl.sub_region2 sub_region2,
				ajl.available_to_sell,
				'8C8DD7E6-EA08-57D6-6556D3BB74048D54',
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				'AD1724FF-E347-83EA-18FD424840AD5849'			
			FROM aj_loading ajl
			LEFT OUTER JOIN products p ON p.id = ajl.item_number
			WHERE ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
				AND p.id is null
		</cfquery>
		
		<cfquery name="m" datasource="#requestObject.getVar("dsn")#">
			UPDATE aj_loading set action = 'inserted' 
			WHERE action is null AND loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	
		<cfset replaceables = arraynew(1)>
		<cfset arrayappend(replaceables, ",")>
		<cfset arrayappend(replaceables, " ")>
		<cfset arrayappend(replaceables, "*")>
		<cfset arrayappend(replaceables, ".")>
		<cfset arrayappend(replaceables, "*")>
		<cfset arrayappend(replaceables, "()")>
		<cfset arrayappend(replaceables, ")")>
		<cfset arrayappend(replaceables, "(")>
		<cfset arrayappend(replaceables, "*")>
		<cfset arrayappend(replaceables, "/")>
		<cfset arrayappend(replaceables, "\")>
		<cfset arrayappend(replaceables, "$")>
		<cfset arrayappend(replaceables, "''")>
		<cfset arrayappend(replaceables, "&")>
		<cfset arrayappend(replaceables, "?")>

		<cfloop from="1" to="#arraylen(replaceables)#" index="i">
			<cfquery name="replaceable" datasource="#requestObject.getVar("dsn")#">
				UPDATE products
				SET products.urlname = REPLACE(products.urlname,'#replaceables[i]#', '-')
			</cfquery>
		</cfloop>
		
		<cfloop from="1" to="2" index="i">
			<cfquery name="replaceable" datasource="#requestObject.getVar("dsn")#">
				UPDATE products
				SET products.urlname = REPLACE(products.urlname,'--', '-')
			</cfquery>
		</cfloop>
		
		<cfquery name="updatedeletedproducts" datasource="#requestObject.getVar("dsn")#">
			UPDATE products	
			SET deleted = 1
			FROM products p
			LEFT OUTER JOIN aj_loading ajl ON p.id = ajl.item_number AND ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
			WHERE  ajl.id is null
				AND p.siteid =  'AD1724FF-E347-83EA-18FD424840AD5849'
		</cfquery>
		
		<cfquery name="rmextrataxonomies" datasource="#requestObject.getVar("dsn")#">
			DELETE tr
			FROM products p
			INNER JOIN taxonomyRelations tr ON tr.relationid = p.id
			LEFT OUTER JOIN aj_loading ajl ON p.id = ajl.item_number AND ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
			WHERE  ajl.id is null
				AND p.siteid =  'AD1724FF-E347-83EA-18FD424840AD5849'
		</cfquery>
		

		<!--- countries of origin --->
		<cfset check = structnew()>
		<cfset check.taxid = 'country'>
		<cfset check.field = 'country_of_origin'>
		<cfset synchtax(check, more.loadid)>
		
		<!--- regions --->
		<cfset check = structnew()>
		<cfset check.taxid = 'region'>
		<cfset check.field = 'region'>
		<cfset synchtax(check, more.loadid)>
		
		<!--- grape --->
		<cfset check = structnew()>
		<cfset check.taxid = 'grape'>
		<cfset check.field = 'grape'>
		<cfset synchgrapetax(check, more.loadid)>
		
		<!---classification --->
		<cfset check = structnew()>
		<cfset check.taxid = 'classification'>
		<cfset check.field = 'classification'>
		<cfset synchtax(check, more.loadid)>
		
		<!--- color --->
		<cfset check = structnew()>
		<cfset check.taxid = 'color'>
		<cfset check.field = 'color'>
		<cfset synchtax(check, more.loadid)>
		
		<!--- containersize --->
		<cfset check = structnew()>
		<cfset check.taxid = 'containersize'>
		<cfset check.field = 'size_description'>
		<cfset synchtax(check, more.loadid)>
		
		<!--- vintage --->
		<cfset check = structnew()>
		<cfset check.taxid = 'vintage'>
		<cfset check.field = 'vintage'>
		<cfset synchtax(check, more.loadid)>
		
		
		<!---
		<!--- varietal --->
		<cfset check = structnew()>
		<cfset check.taxid = 'varietal'>
		<cfset check.field = 'varietal'>
		<cfset synchtax(check, more.loadid)>
		--->
		<cfset synchProdCats(more.loadid)>
		
		
		
		<!--- set money relationships --->
		<!--- UNIT --->
		<cfquery name="updateforexistingUNIT" datasource="#requestObject.getVar("dsn")#">
			UPDATE productPrices
			SET 
				productPrices.price = CAST(aj_loading.unit_retail as REAL),
				productPrices.price_sale = CAST(aj_loading.unit_sale_retail as REAL),
				productPrices.price_member = CAST(aj_loading.web_unit_sale as REAL),
				productPrices.changedby = '8C8DD7E6-EA08-57D6-6556D3BB74048D54',
				productPrices.modified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
			FROM  productPrices pp
			INNER JOIN aj_loading ON pp.productid = aj_loading.item_number AND aj_loading.loadid = '#more.loadid#'
			WHERE pp.type = 'unit'
		</cfquery>

		
		<cfquery name="updateforexistingPACK" datasource="#requestObject.getVar("dsn")#">
			UPDATE productPrices
			SET 
				productPrices.price = CAST(aj_loading.pack_retail as REAL),
				productPrices.price_sale = CAST(aj_loading.pack_sale_price as REAL),
				productPrices.price_member = CAST(aj_loading.web_pack_sale as REAL),
				productPrices.changedby = '8C8DD7E6-EA08-57D6-6556D3BB74048D54',
				productPrices.modified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
			FROM  productPrices pp
			INNER JOIN aj_loading ON pp.productid = aj_loading.item_number AND aj_loading.loadid = '#more.loadid#'
			WHERE pp.type = 'pack'
		</cfquery>
		
		<cfquery name="updateforexistingCASE" datasource="#requestObject.getVar("dsn")#">
			UPDATE productPrices
			SET 
				productPrices.price = CAST(aj_loading.warm_case_retail as REAL),
				productPrices.price_sale = CAST(aj_loading.case_sale_retail as REAL),
				productPrices.price_member = CAST(aj_loading.web_case_sale as REAL),
				productPrices.changedby = '8C8DD7E6-EA08-57D6-6556D3BB74048D54',
				productPrices.modified = <cfqueryparam value="#now()#" cfsqltype="cf_sql_date">
			FROM  productPrices  pp
			INNER JOIN aj_loading ON pp.productid = aj_loading.item_number AND aj_loading.loadid = '#more.loadid#'
			WHERE pp.type = 'case'
		</cfquery>
		
		
		<cfquery name="insertfornewunit" datasource="#requestObject.getVar("dsn")#">
			INSERT INTO productPrices (productid, type, price, price_sale, price_member, modified, created, changedby)
			SELECT 
				ajl.item_number,
				'unit',
				CAST(ajl.unit_retail as REAL),
				CAST(ajl.unit_sale_retail as REAL),
				CAST(ajl.web_unit_sale as REAL),
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				'8C8DD7E6-EA08-57D6-6556D3BB74048D54'
			FROM aj_loading ajl
			LEFT OUTER JOIN productPrices pp ON 
				pp.productid = ajl.item_number 
				AND pp.type = 'unit'
			WHERE 
				pp.id is null
				AND ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfquery name="insertfornewpack" datasource="#requestObject.getVar("dsn")#">
			INSERT INTO productPrices (productid, type, price, price_sale, price_member, modified, created, changedby)
			SELECT 
				ajl.item_number,
				'pack',
				CAST(ajl.pack_retail as REAL),
				CAST(ajl.pack_sale_price as REAL),
				CAST(ajl.web_pack_sale as REAL),
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				'8C8DD7E6-EA08-57D6-6556D3BB74048D54'
			FROM aj_loading ajl
			LEFT OUTER JOIN productPrices pp ON 
				pp.productid = ajl.item_number 
				AND pp.type = 'pack'
			WHERE 
				pp.id is null
				AND ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfquery name="insertfornewcase" datasource="#requestObject.getVar("dsn")#">
			INSERT INTO productPrices (productid, type, price, price_sale, price_member, modified, created, changedby)
			SELECT 
				ajl.item_number,
				'case',
				CAST(ajl.warm_case_retail as REAL),
				CAST(ajl.case_sale_retail as REAL),
				CAST(ajl.web_case_sale as REAL),
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
				'8C8DD7E6-EA08-57D6-6556D3BB74048D54'
			FROM aj_loading ajl
			LEFT OUTER JOIN productPrices pp ON 
				pp.productid = ajl.item_number 
				AND pp.type = 'case'
			WHERE 
				pp.id is null
				AND CAST(ajl.warm_case_retail AS real) <> 0 AND ajl.warm_case_retail is not null
				AND ajl.loadid = <cfqueryparam value="#more.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<!--- some taxonomiies may of been added, update the safename --->
		<cfquery name="nosafename" datasource="#requestObject.getVar("dsn")#">
			SELECT * FROM taxonomyitems WHERE safename IS NULL
		</cfquery>
		
		<cfset cnt = 0>
		<cfoutput>
		<cfloop query="nosafename">
			<cfset newsafename = trim(nosafename.name)>
			<cfset newsafename = rereplacenocase(newsafename, "[^a-z0-9]", "_","all")>
			<cfset safeok = 0>
			<cfloop condition="safeok EQ 0">
				<cfquery name="issafename" datasource="#requestObject.getVar("dsn")#" result="m">
					SELECT count(*) cnt FROM taxonomyitems WHERE safename = <cfqueryparam value="#newsafename#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<cfif issafename.cnt EQ 0>
					<cftry>
					<cfquery name="issafename" datasource="#requestObject.getVar("dsn")#">
						UPDATE taxonomyitems SET safename = <cfqueryparam value="#newsafename#" cfsqltype="cf_sql_varchar">
						WHERE id = <cfqueryparam value="#nosafename.id#">
					</cfquery>
					<cfcatch>
						<cfoutput>update safename faild on #nosafename.id# with name = #newsafename#</br></cfoutput>
					</cfcatch>
					</cftry>
					<cfset safeok = 1>
				<cfelse>
					<cfset newsafename = newsafename & "1">
				</cfif>
				
				<cfif cnt GT 1000><cfabort></cfif>
				<cfset cnt = cnt + 1>
			</cfloop>
		</cfloop>	
		</cfoutput>
		
		<!--- set "other" items as deleted --->
		<cfquery name="deleteothers" datasource="#requestObject.getVar("dsn")#">
			UPDATE p
			SET 
				p.deleted = 1
			FROM  products p
			INNER JOIN taxonomyRelations tr ON tr.relationid = p.id 
			INNER JOIN taxonomyItems ti ON ti.id = tr.taxonomyitemid AND ti.taxonomyid = 'product_categories' AND ti.name = 'other'
		</cfquery>
		
	<!--- manage isdefault key for default price view and sorts --->
		<!--- clear default prices --->
		<cfquery name="clear_all_default_prices" datasource="#requestObject.getVar("dsn")#">
			UPDATE pp
			SET 
				pp.isdefault = 0
			FROM  productPrices pp
		</cfquery>
		
		<!--- try to set pack as default for beer type if pack price is not 0 --->
		<cfquery name="unit_as_default_price_for_beer" datasource="#requestObject.getVar("dsn")#">
			UPDATE pp
			SET 
				pp.isdefault = 1
			FROM  productprices pp
			INNER JOIN taxonomyRelations tr ON pp.productid = tr.relationid
			INNER JOIN taxonomyItems ti ON tr.taxonomyitemid = ti.id AND (ti.name = 'beer' OR ti.name = 'wine')
			WHERE pp.type = 'pack' AND pp.price <> 0
		</cfquery>
		
		<!--- try to set unit as default if unit price is not 0 --->
		<cfquery name="unit_as_default_price_for_default" datasource="#requestObject.getVar("dsn")#">
			UPDATE pp
			SET 
				pp.isdefault = 1
			FROM  productPrices pp
			WHERE type = 'unit' AND price <> 0 AND (SELECT count(*) FROM productPrices spp WHERE spp.productid = pp.productid AND spp.isdefault = 1) = 0
		</cfquery>
		
		<cfquery name="unit_as_default_price_for_default" datasource="#requestObject.getVar("dsn")#">
			UPDATE pp
			SET 
				pp.isdefault = 1
			FROM  productPrices pp
			WHERE type = 'pack' AND price <> 0 AND (SELECT count(*) FROM productPrices spp WHERE spp.productid = pp.productid AND spp.isdefault = 1) = 0
		</cfquery>
		
		<cfquery name="unit_as_default_price_for_default" datasource="#requestObject.getVar("dsn")#">
			UPDATE pp
			SET 
				pp.isdefault = 1
			FROM  productPrices pp
			WHERE type = 'case' AND price <> 0 AND (SELECT count(*) FROM productPrices spp WHERE spp.productid = pp.productid AND spp.isdefault = 1) = 0
		</cfquery>
		
		<cfset synchPriceCats(more.loadid)>
		
		<!--- maybbe should activate to track?
		<cffile 
		   action="copy"
		   source="#lcl.filename#"
		   destination="#lcl.filename#-#dateformat(now(),"yyyy-mm-dd")#-#timeformat(now(),"HH-mm-ss")#">
		--->
		<cfabort>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="synchtax">
		<cfargument name="more">
		<cfargument name="loadid">
		
		<!--- 
			this query gets all the items that do not have taxonomies 
			from the columns that turn into taxonomies
		 --->
		<cfquery name="blankitems" datasource="#requestObject.getVar("dsn")#">
			SELECT distinct ajl.#check.field# fname
			FROM aj_loading ajl
			LEFT OUTER JOIN taxonomyitems ti ON ti.name = ajl.#check.field# AND ti.taxonomyid = '#check.taxid#'
			WHERE ti.id is null AND ajl.loadid = <cfqueryparam value="#loadid#" cfsqltype="cf_sql_varchar">
				AND ajl.#check.field# <> 'na' AND ajl.#check.field# <> '' AND ajl.#check.field# is not null
			ORDER BY ajl.#check.field#
		</cfquery>
		
		<!--- using above q, add new taxonomies --->
		<cfloop query="blankitems">
			<cfset name = fname>
			<cfset name = ucase(mid(name,1,1)) & lcase(mid(name, 2,len(name)))>
			<cfif len(name) GT 50>
				<cfset name = left(name, 50)>
			</cfif>
			<cfquery name="insertba" datasource="#requestObject.getVar("dsn")#">
				INSERT INTO taxonomyitems (id,name,description, changedby,deleted,created,modified,taxonomyid,sortkey) 
				VALUES (
					<cfqueryparam value="#createuuid()#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#name#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="8C8DD7E6-EA08-57D6-6556D3BB74048D54" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="0" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#now()#" cfsqltype="cf_sql_date">,
					<cfqueryparam value="#check.taxid#" cfsqltype="cf_sql_varchar">,
					<cfqueryparam value="#currentrow#" cfsqltype="cf_sql_varchar">					
				)
			</cfquery>
		</cfloop>
		
		<!--- 
			This query clears out taxonomy relations that are related to products for reinsertion 
			- maybe refactor to udpate and insert
		 --->
		 
		<cftransaction>
		<cfquery name="deleteproducttaxrels" datasource="#requestObject.getVar("dsn")#">
			DELETE tr	
			FROM  taxonomyrelations tr
			INNER JOIN aj_loading ON 
				relationid = aj_loading.item_number 
				AND aj_loading.loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			INNER JOIN taxonomyItems ti ON tr.taxonomyItemId = ti.id
			WHERE 
				tr.relationtype = 'products'
				AND ti.taxonomyid = <cfqueryparam value="#check.taxid#" cfsqltype="cf_sql_varchar">
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
				ajl.item_number,
				'AD1724FF-E347-83EA-18FD424840AD5849'	
			FROM aj_loading ajl
			INNER JOIN taxonomyitems ti ON 
				ti.taxonomyid = <cfqueryparam value="#check.taxid#" cfsqltype="cf_sql_varchar">
				AND ti.name = ajl.#check.field#
			WHERE ajl.loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		</cftransaction>
			
	</cffunction>
	
	<cffunction name="synchgrapetax">
		<cfargument name="more">
		<cfargument name="loadid">
		
		<!--- Grapes done seperately --->
	</cffunction>
	
	<cffunction name="synchprodcats">
		<cfargument name="loadid">
		<cfset var taxid = 'product_categories'>
		<!--- 
			this query inserts categories if any are missing.
		 --->
		<cfset var cats = structnew()>
		<cfset cats.other = arraynew(1)>
		<cfset arrayappend(cats.other,"other categories")>
		<cfset arrayappend(cats.other,"soda")>
		<cfset arrayappend(cats.other,"mixes")>
		<cfset arrayappend(cats.other,"cigarettes")>
		
		<cfset cats.wine = arraynew(1)>
		<cfset arrayappend(cats.wine,"imported wine")>
		<cfset arrayappend(cats.wine,"domestic wine")>
		
		<cfset cats.beer = arraynew(1)>
		<cfset arrayappend(cats.beer,"beer")>
		
		<cfset cats.cordials_liqueurs = arraynew(1)>
		<cfset arrayappend(cats.cordials_liqueurs,"cordials")>
		
		<cfset cats.spirits = arraynew(1)>
		<cfset arrayappend(cats.spirits,"liquor")>
		
		<cfquery name="checkitemcount" datasource="#requestObject.getVar("dsn")#">
			SELECT name FROM taxonomyItems
			WHERE taxonomyid = 'product_categories'
				AND name IN ('#replace(structkeylist(cats, "','"),"_"," ")#')
		</cfquery>
		
		<cfif checkitemcount.recordcount NEQ listlen(structkeylist(cats,","))>
			<H1>NOT CORRECT AMOUNT OF CATEGORIES</H1>
			<cfdump var="#checkitemcount#">
		</cfif>
		
		<!--- clearout existing 
			- maybe refactor with above q to udpate and insert
		--->
		
		<cftransaction>
		<cfquery name="deleteproducttaxrels" datasource="#requestObject.getVar("dsn")#">
			DELETE tr	
			FROM  taxonomyrelations tr
			INNER JOIN aj_loading ON 
				relationid = aj_loading.item_number 
				AND aj_loading.loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			INNER JOIN taxonomyItems ti ON tr.taxonomyItemId = ti.id
			WHERE 
				tr.relationtype = 'products'
				AND ti.taxonomyid = 'product_categories'
				AND tr.siteid = 'AD1724FF-E347-83EA-18FD424840AD5849'
		</cfquery>
		
		<!--- 
			This looped query reinserts taxonomy relations that are related to products 
			- maybe refactor with above q to udpate and insert 
		--->
		<cfloop collection="#cats#" item="cat">
			<cfquery name="reinsertproducttaxrels" datasource="#requestObject.getVar("dsn")#" result="m">
				INSERT INTO taxonomyrelations (taxonomyitemid, relationtype, relationid, siteid)
				SELECT 
					ti.id,
					'products',
					ajl.item_number,
					'AD1724FF-E347-83EA-18FD424840AD5849'	
				FROM aj_loading ajl
				INNER JOIN taxonomyitems ti ON 
					ti.taxonomyid = <cfqueryparam value="#taxid#" cfsqltype="cf_sql_varchar">
					AND ti.name = <cfqueryparam value="#replace(cat,"_"," ")#" cfsqltype="cf_sql_varchar">
					AND ajl.group_name IN ('#arraytolist(cats[cat],"','")#')
				WHERE ajl.loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- <cfdump var=#m#> --->
		</cfloop>
		</cftransaction>
				
	</cffunction>
	
	<cffunction name="synchpricecats">
		<cfargument name="loadid">
				 
		<cftransaction>
		<cfquery name="deleteproducttaxrels" datasource="#requestObject.getVar("dsn")#">
			DELETE tr	
			FROM  taxonomyrelations tr
			INNER JOIN aj_loading ON 
				relationid = aj_loading.item_number 
				AND aj_loading.loadid = <cfqueryparam value="#arguments.loadid#" cfsqltype="cf_sql_varchar">
			INNER JOIN taxonomyItems ti ON tr.taxonomyItemId = ti.id
			WHERE 
				tr.relationtype = 'products'
				AND ti.taxonomyid = 'price'
				AND tr.siteid = 'AD1724FF-E347-83EA-18FD424840AD5849'
		</cfquery>
		
		<cfquery name="priceitems" datasource="#requestObject.getVar("dsn")#">
			SELECT id, name, description FROM taxonomyItems
			WHERE taxonomyid = 'price'
		</cfquery>

		<!--- 
			This looped query reinserts taxonomy relations that are related to prices 
		--->
		<cfloop query="priceitems">
			<cfset pricelim = structnew()>
			
			<cfif listlen(description,"-") EQ 2>
				<cfset pricelim.from = listfirst(description,"-")>
				<cfset pricelim.to = listlast(description,"-")>
			<cfelse>
				<cfset pricelim.from = replace(description, "+","")>
			</cfif>

			<cfquery name="reinsertproducttaxrels" datasource="#requestObject.getVar("dsn")#" result="m">
				INSERT INTO taxonomyrelations (taxonomyitemid, relationtype, relationid, siteid)
				SELECT 
					ti.id,
					'products',
					pp.productid,
					'AD1724FF-E347-83EA-18FD424840AD5849'	
				FROM productprices pp
				INNER JOIN taxonomyitems ti ON 
					ti.id = <cfqueryparam value="#priceitems.id#" cfsqltype="cf_sql_varchar">
				WHERE
					pp.isdefault = 1
					AND pp.price >= <cfqueryparam value="#pricelim.from#" cfsqltype="cf_sql_real">
					<cfif structkeyexists(pricelim, "to")>
						AND pp.price < <cfqueryparam value="#pricelim.to#" cfsqltype="cf_sql_real">
					</cfif>
			</cfquery>

		</cfloop>
		</cftransaction>
		
	</cffunction>
	
	<cffunction name="process_load_item">
		<cfargument name="rowdata" required="true">
		<cfargument name="more" required="true">
		<cfset var list = structkeylist(rowdata)>
		<cfset var ditem = "">
		<cftry>
			<cfset rowdata['item_number'] = int(rowdata['item_number'])>
			<cfquery name="m" datasource="#requestObject.getVar("dsn")#">
				INSERT INTO aj_loading (#list#,loadid,loadts)
				VALUES
				(	
					<cfloop list="#list#" index="ditem">
						<cfqueryparam value="#rowdata[ditem]#" cfsqltype="cf_sql_varchar">,
					</cfloop>
					<cfqueryparam value="#more["loadid"]#" cfsqltype="cf_sql_varchar">
					,<cfqueryparam value="#more["loadts"]#" cfsqltype="cf_sql_date">
				)
			</cfquery>
			<cfcatch>
				<cfdump var=#rowdata#>
				<cfdump var=#cfcatch#>
				<cfabort>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<cffunction	name="CSVToArray" required="true">
		<cfargument	name="File" required="true"/>
		<cfargument	name="CSV" required="false" default=""/>
		<cfargument	name="Delimiter" required="false" default=","/>		 
		<cfargument name="Trim" type="boolean" required="false" default="true"/>

		<cfset var lcl = StructNew() />
									 
		<!---
		Check to see if we are using a CSV File. If so,
		then all we want to do is move the file data into
		the CSV variable. That way, the rest of the algorithm
		can be uniform.
		--->
		<cfif Len( ARGUMENTS.File )>
				 
			<!--- Read the file into Data. --->
			<cffile
			action="read"
			file="#ARGUMENTS.File#"
			variable="ARGUMENTS.CSV"
			/>
			<cfset arguments.csv = replace(arguments.csv, '"',"","all")>
		</cfif>
				 
		<!---
		Check to see if we need to trim the data. Be default,
		we are going to pull off any new line and carraige
		returns that are at the end of the file (we do NOT want
		to strip spaces or tabs).
		--->
		<cfif ARGUMENTS.Trim>
				 
			<!--- Remove trailing returns. --->
			<cfset ARGUMENTS.CSV = REReplace(
			ARGUMENTS.CSV,
			"[\r\n]+$",
			"",
			"ALL"
			) />
				 
		</cfif>
				 
				 
		<!--- Make sure the delimiter is just one character. --->
		<cfif (Len( ARGUMENTS.Delimiter ) NEQ 1)>
			<!--- Set the default delimiter value. --->
			<cfset ARGUMENTS.Delimiter = "," />
		</cfif>
	 
		<!---
		Create a compiled Java regular expression pattern object
		for the experssion that will be needed to parse the
		CSV tokens including the field values as well as any
		delimiters along the way.
		--->
		<cfset LOCAL.Pattern = CreateObject(
				"java",
				"java.util.regex.Pattern"
				).Compile(
				JavaCast(
				"string",
				 
		<!--- Delimiter. --->
				"\G(\#ARGUMENTS.Delimiter#|\r?\n|\r|^)" &
				 
		<!--- Quoted field value. --->
				"(?:""([^""]*+(?>""""[^""]*+)*)""|" &
				 
		<!--- Standard field value --->
				"([^""\#ARGUMENTS.Delimiter#\r\n]*+))"
				)
				)
				/>
				 
		<!---
		Get the pattern matcher for our target text (the
		CSV data). This will allows us to iterate over all the
		tokens in the CSV data for individual evaluation.
		--->
		<cfset LOCAL.Matcher = LOCAL.Pattern.Matcher(
		JavaCast( "string", ARGUMENTS.CSV )
		) />
				 
				 
		<!---
		Create an array to hold the CSV data. We are going
		to create an array of arrays in which each nested
		array represents a row in the CSV data file.
		--->
		<cfset LOCAL.Data = ArrayNew( 1 ) />
				 
		<!--- Start off with a new array for the new data. --->
		<cfset ArrayAppend( LOCAL.Data, ArrayNew( 1 ) ) />
				 
				 
		<!---
		Here's where the magic is taking place; we are going
		to use the Java pattern matcher to iterate over each
		of the CSV data fields using the regular expression
		we defined above.
		 
		Each match will have at least the field value and
		possibly an optional trailing delimiter.
		--->
		<cfloop condition="LOCAL.Matcher.Find()">
				 
			<!---
			Get the delimiter. We know that the delimiter will
			always be matched, but in the case that it matched
			the START expression, it will not have a length.
			--->
			<cfset LOCAL.Delimiter = LOCAL.Matcher.Group(
			JavaCast( "int", 1 )
			) />
					 
					 
			<!---
			Check for delimiter length and is not the field
			delimiter. This is the only time we ever need to
			perform an action (adding a new line array). We
			need to check the length because it might be the
			START STRING match which is empty.
			--->
			<cfif (	Len( LOCAL.Delimiter ) AND	(LOCAL.Delimiter NEQ ARGUMENTS.Delimiter) )>
					 
			<!--- Start new row data array. --->
			<cfset ArrayAppend(
				LOCAL.Data,
				ArrayNew( 1 )
			) />
					 
			</cfif>
					 
					 
			<!---
			Get the field token value in group 2 (which may
			not exist if the field value was not qualified.
			--->
			<cfset LOCAL.Value = LOCAL.Matcher.Group(
				JavaCast( "int", 2 )
			) />
					 
			<!---
			Check to see if the value exists. If it doesn't
			exist, then we want the non-qualified field. If
			it does exist, then we want to replace any escaped
			embedded quotes.
			--->
			<cfif StructKeyExists( LOCAL, "Value" )>
					 
				<!---
				Replace escpaed quotes with an unescaped double
				quote. No need to perform regex for this.
				--->
				<cfset LOCAL.Value = Replace(
				LOCAL.Value,
				"""""",
				"""",
				"all"
				) />
					 
			<cfelse>
					 
				<!---
				No qualified field value was found, so use group
				3 - the non-qualified alternative.
				--->
				<cfset LOCAL.Value = LOCAL.Matcher.Group(
				JavaCast( "int", 3 )
				) />
					 
			</cfif>
					 
					 
			<!--- Add the field value to the row array. --->
			<cfset ArrayAppend(
				LOCAL.Data[ ArrayLen( LOCAL.Data ) ],
				LOCAL.Value
			) />
				 
		</cfloop>
				 
				 
		<!---
		At this point, our array should contain the parsed
		contents of the CSV value. Return the array.
		--->
		<cfreturn LOCAL.Data />
	</cffunction>
</cfcomponent>
