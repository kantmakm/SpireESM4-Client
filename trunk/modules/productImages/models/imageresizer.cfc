<cfcomponent name="productcatalogimageresizer" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset clear()>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="clear">
		<cfset variables.maxw = 0>
		<cfset variables.maxh = 0>
		<cfset variables.imageid = "">
	</cffunction>
	
	<cffunction name="setImageid">
		<cfargument name="imageid" required="true">
		<cfset variables.imageid = arguments.imageid>
	</cffunction>
	
	<cffunction name="setwidth">
		<cfargument name="mw" required="true">
		<cfset variables.maxw = mw>
	</cffunction>
	
	<cffunction name="setheight">
		<cfargument name="mh" required="true">
		<cfset variables.maxh = mh>
	</cffunction>

	<cffunction name="process">
		<cfset var lcl = structnew()>

		<cfset variables.resizefilename = variables.imageid>
		<cfset variables.resizefilename = variables.resizefilename & "_w" & variables.maxw>
		
		<cfif variables.maxh>
			<cfset lcl.str = variables.resizefilename & "_h" & variables.maxh>
		</cfif>
		
		<!--- if image is found --->
		<cfif fileexists(requestObject.getVar("machineroot") & "/ui/productimages/" & variables.imageid & '/' & variables.resizefilename & ".jpg")>
			<cfreturn true>
		</cfif>
		
		<!--- if base image is not found return false--->
		<cfset lcl.baseimage = requestObject.getVar("machineroot") & "/ui/productimages/" & variables.imageid & '/' & variables.imageid & ".jpg">
		
		<cfif NOT fileexists(lcl.baseimage)>
			<cfreturn false>
		</cfif>
		
		<!--- can recreate --->
		<cfset lcl.targetimage = requestObject.getVar("machineroot") & "/ui/productimages/" & variables.imageid & '/' & variables.resizefilename & ".jpg">
		<cfset lcl.imgmgr = createObject("component", "utilities.imagemanipulation").init(requestObject)>
		<cfif variables.maxh AND variables.maxw>
			<cfset lcl.imgmgr.resizetomax(lcl.baseimage, variables.maxw, variables.maxh, lcl.targetimage)>
		<cfelseif variables.maxh OR variables.maxw>
			<cfset lcl.imgmgr.resize(lcl.baseimage, iif(variables.maxw EQ 0, DE(""), 'variables.maxw'), iif(variables.maxh EQ 0,DE(""), 'variables.maxh'), lcl.targetimage)>
		<cfelse>
			<cfthrow message="need min width or height for image #variables.imageid#">
		</cfif>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getImagePath">
		<cfreturn "/ui/productimages/" & variables.imageid & '/' & variables.resizefilename & ".jpg">	
	</cffunction>
	
</cfcomponent>
