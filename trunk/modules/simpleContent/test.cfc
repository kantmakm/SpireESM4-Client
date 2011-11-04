<cfcomponent displayname="MyCFCTest" extends="mxunit.framework.TestCase">
		
	<cffunction name="setUp" returntype="void" access="public">
		<cfset variables.requestObject = request.requestObject>         
	</cffunction>
    
    <cffunction name="loadController" access="private">
    	<cfargument name="str">
        <cfset var data = structnew()>
        <cfset data.content = arguments.str>
    	<cfset variables.controller = createObject("component","modules.simplecontent.controller").init(
			data=data,
			requestObject=variables.requestObject,
			pageRef = "hi",
			name = "default"
		)>
    </cffunction>
    
    <cffunction name="teardown" returntype="void" access="public">
	
	</cffunction>
	
    <cffunction name="testinout">
    	<cfset var str = "hello">
        <cfset var out = "">
    	<cfset loadController(str)>
		<cfset out = variables.controller.showHTML()>
        <cfset assertequals(expected=str,actual=out)>
    </cffunction>
       
</cfcomponent>