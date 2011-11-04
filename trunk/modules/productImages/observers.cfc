<cfcomponent name="ajobservers"  extends="resources.abstractObserver">

	<cffunction name="moduleoutput_dhtmlpager">
		<cfargument name="observed" required="true">
		<cfreturn parseContent(observed)>
	</cffunction>
	
	<cffunction name="moduleoutput_htmlcontent">
		<cfargument name="observed" required="true">
		<cfreturn parseContent(observed)>
	</cffunction>
	
	<cffunction name="parseContent">
		<cfargument name="data" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfset lcl.html = data.html>
		
		<cfset lcl.r = refindnocase("\[([0-9]+):w([0-9]+):h([0-9]+)\]", lcl.html, 1, true )>

		<cfloop condition="lcl.r.pos[1] NEQ 0">
			<cfset lcl.itemid = mid(lcl.html, lcl.r.pos[2], lcl.r.len[2])>
			<cfset lcl.width = mid(lcl.html, lcl.r.pos[3], lcl.r.len[3])>
			<cfset lcl.height = mid(lcl.html, lcl.r.pos[4], lcl.r.len[4])>
			
			<cfif not structkeyexists(variables, "resizer")>
				<cfset variables.resizer = createObject("component", "modules.productImages.models.imageresizer").init(requestobject)>
			</cfif>
			
			<cfset variables.resizer.clear()>
			<cfset variables.resizer.setImageId(lcl.itemid)>
			<cfset variables.resizer.setWidth(lcl.width)>
			<cfset variables.resizer.setHeight(lcl.height)>
			
			<!--- in case base image is not found, give default --->
			<cfif NOT variables.resizer.process()>
				<cfset variables.resizer.setImageId("default")>
				<cfset variables.resizer.process()>
			</cfif>
			
			<cfset lcl.imgpath = variables.resizer.getImagePath()>
				
			<cfset lcl.thtml = mid(lcl.html, 1, lcl.r.pos[1]-1)>
			<cfset lcl.thtml = lcl.thtml & lcl.imgpath>
			<cfset lcl.html = lcl.thtml & mid(lcl.html, lcl.r.pos[1] + lcl.r.len[1], len(lcl.html))>

			<cfset lcl.r = refindnocase("\[[0-9]+:w[0-9]+:h[0-9]+\]", lcl.html, 1, true )>
		</cfloop>
		
		<cfset arguments.data.html = lcl.html>
		
		<cfreturn arguments.data>
	</cffunction>
	
</cfcomponent>