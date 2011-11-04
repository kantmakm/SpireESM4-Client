<!--- 
 Extends the base Assertions ... assertEquals and AssertTrue ...
 --->
<cfcomponent displayname="MXUnitAssertionExtensions" extends="Assert" output="false" hint="Extends core mxunit assertions."> 
   
   <cfparam name="request.__mxunitInheritanceTree__" type="string" default="" />

  <cffunction name="assertIsXMLDoc" access="public" returntype="boolean">
     <cfargument name="xml" required="yes" type="any" />
	 <cfargument name="message" required="no" default="The test result is not a valid ColdFusion XML DOC object." type="string">
    
  	<cfset assertTrue(isXMLDoc(arguments.xml),arguments.message)>
  	<cfreturn true>
   </cffunction>


  <cffunction name="assertIsEmptyArray" access="public" returntype="boolean">
  	 <cfargument name="a" required="yes" type="any" />
 	 <cfargument name="message" required="no" default="The test result is NOT an empty ARRAY. It has #ArrayLen(arguments.a)# elements" type="string">
    <cfset assertEquals(0,ArrayLen(arguments.a),arguments.message)>
	<cfreturn true>
   </cffunction>


  <cffunction name="assertIsArray" access="public" returntype="boolean">
     <cfargument name="a" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion ARRAY."/>
    	<cfset assertTrue(isArray(arguments.a),arguments.message)> 
		<cfreturn true>
   </cffunction>


  <cffunction name="assertIsEmptyQuery" access="public" returntype="boolean">
     <cfargument name="q" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="There should be 0 records returned but there were #arguments.q.recordcount#"/>
    	<cfset assertEquals(0,arguments.q.recordcount,arguments.message)> 
		<cfreturn true>
   </cffunction>


  <cffunction name="assertIsQuery" access="public" returntype="boolean">
     <cfargument name="q" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion QUERY."/>
    	<cfset assertTrue(isQuery(arguments.q),arguments.message)>
		<cfreturn true>
   </cffunction>


  <cffunction name="assertIsStruct" access="public" returntype="boolean">
     <cfargument name="struct" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion STRUCTURE."/>
    	<cfset assertTrue(isStruct(arguments.struct),arguments.message)>
		<cfreturn true>
   </cffunction>


   <cffunction name="assertIsEmptyStruct" access="public" returntype="boolean">
     <cfargument name="struct" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="The test result is NOT an empty STRUCTURE. It has #StructCount(arguments.struct)# top-level keys"/>
    	<cfset assertEquals(0,StructCount(arguments.Struct),arguments.message)> 
		<cfreturn true>
   </cffunction>


   <cffunction name="assertIsEmpty" access="public" returntype="boolean">
     <cfargument name="o" required="yes" type="String" />
	 <cfargument name="message" type="string" required="false" default="The test result is NOT EMPTY. It is [#o#]"/>
		<cfset assertEquals("",o,arguments.message)>
     <cfreturn true>
  </cffunction>

  <cffunction name="assertIsDefined" access="public" returntype="boolean">
     <cfargument name="o" required="yes" type="any" />
	 <cfargument name="message" type="string" required="false" default="The value [#arguments.o#] is NOT DEFINED"/>
    	<cfset assertTrue( isDefined(evaluate("arguments.o")) , arguments.message )>
		<cfreturn true>
  </cffunction>




  <cffunction name="assertIsTypeOf" access="public" returntype="boolean">
     <cfargument name="o" required="yes" type="WEB-INF.cftags.component" />
     <cfargument name="type" required="yes" type="string" />
		 <cfset var md = getMetaData(o)>
		 <cfset var oType = md.name>
     <cfset var ancestory = buildInheritanceTree(md) />
     <cfset var message = "The object [#oType#] is not of type #arguments.type#. Searched inheritance tree: [#ancestory#]">
     <cfif listFindNoCase(ancestory,arguments.type) eq 0>
       <cfset fail(message)>
     </cfif>
    	<cfreturn true>
   </cffunction>



  
  
  <cffunction name="buildInheritanceTree" access="public" returntype="string">
    <cfargument name="metaData" type="struct" />
    
    <cfscript>
    if( listFindNoCase(request.__mxunitInheritanceTree__,arguments.metaData.name) eq 0 ){
      request.__mxunitInheritanceTree__ =  request.__mxunitInheritanceTree__ & arguments.metaData.name & ",";
    }
     if(isDefined("arguments.metaData.extends")){
       buildInheritanceTree(metaData.extends);
     }
     return  request.__mxunitInheritanceTree__;
    </cfscript>
  </cffunction>


</cfcomponent>