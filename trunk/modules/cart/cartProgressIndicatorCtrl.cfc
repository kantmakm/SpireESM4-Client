<cfcomponent name="cartProgressIndicator" output="false" extends="resources.abstractSubController">
	<cffunction name="showHTML">
		<cfset var lcl = structnew()>
		
		<cfset lcl.corder = createObject("component", "modules.cart.models.cart").init(variables.requestObject).checkoutorder()>
		<cfset lcl.rows = arraylen(lcl.corder)-1>
		<cfset lcl.path = "/" & requestObject.getFormUrlVar("path")>
		<cfset lcl.back = 1>
		<cfoutput>
		<cfsavecontent variable="lcl.html">
		<ul>
		<cfloop from="1" to="#lcl.rows#" index="lcl.idx">
			<cfsilent>
				<cfset lcl.itm = lcl.corder[lcl.idx]>
					
				<cfset lcl.classes = "">
				<cfif lcl.idx EQ 1><cfset lcl.classes = lcl.classes & " " & "first"></cfif>
				<cfif lcl.idx EQ lcl.rows><cfset lcl.classes = lcl.classes & " " & "last"></cfif>
	
				<cfif lcl.itm.page & "/" EQ lcl.path>
					<cfset lcl.classes = lcl.classes & "current">
					<cfset lcl.back = 0>
				</cfif>
				
				<cfif lcl.idx NEQ lcl.rows>
					<cfif lcl.corder[lcl.idx + 1].page & "/" EQ lcl.path>
						<cfset lcl.classes = lcl.classes & "before">
					</cfif>
				</cfif>
			</cfsilent>
			<li<cfif lcl.classes NEQ ""> class="#trim(lcl.classes)#"</cfif>>
				<cfif lcl.back><a href="#lcl.itm.page#">STEP #lcl.idx#: #lcl.itm.label#</a>
				<cfelse><span>STEP #lcl.idx#: #lcl.itm.label#</span>
				</cfif>
			</li>			
		</cfloop>
		</ul>
		</cfsavecontent>
		</cfoutput>
		
		<cfreturn lcl.html>
	</cffunction>
</cfcomponent>