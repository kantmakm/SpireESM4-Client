<cfcomponent name="mxunit.framework.RemoteFacade" hint="Main default interface into MXUnit framework from the MXUnit Ecplise Plugin.">
	
	<cfset cu = createObject("component","ComponentUtils")>
	<cfset cache = createObject("component","RemoteFacadeObjectCache")>
	<cfset ConfigManager = createObject("component","ConfigManager")>
	
	<cffunction name="ping" output="false" access="remote" returntype="boolean" hint="returns true">
		<cfreturn true>
	</cffunction>
	
	<cffunction name="initializeSuitePool" access="remote" returntype="void">
		<cfset cache.initializeSuitePool()>
	</cffunction>
	
	<cffunction name="purgeSuitePool" access="remote" returntype="numeric">
		<cfreturn cache.purgeSuitePool()>
	</cffunction>
	
	<cffunction name="getServerType" output="false" access="remote" returntype="String" hint="returns the server type, whether coldfusion or bluedragon">
		<cfreturn server.ColdFusion.ProductName>
	</cffunction>
	
	<cffunction name="startTestRun" access="remote" returntype="string">
		<cfset var useCache = false>
		<cfset ConfigManager.ConfigManager()>		
		<cfset useCache = configManager.getConfigElementValue("pluginControl","UseRemoteFacadeObjectCache")>
		
		<cfif useCache>
			<cfreturn cache.startTestRun()>
		<cfelse>
			<cfreturn "">
		</cfif>
			
	</cffunction>
	
	<cffunction name="getObject" access="package" returntype="any">
		<cfargument name="componentName" type="String" required="true">
		<cfargument name="testRunKey" type="string" required="true" hint="the key returned from startTestRun; used for managing the pool of components">
		<cfreturn cache.getObject(componentName,testRunKey)>
	</cffunction>
	
	<cffunction name="endTestRun" access="remote" returntype="string" hint="ensures proper cleanup">
		<cfargument name="TestRunKey" type="string" required="true" hint="the key returned from startTestRun; used for managing the pool of components">
		<cfreturn cache.endTestRun(TestRunKey)>
	</cffunction>
	
	<cffunction name="executeTestCase" access="remote" returntype="struct">
		<cfargument name="componentName" type="String" required="true">
		<cfargument name="methodNames" type="String" required="true" hint="pass empty string to run all methods. pass list of valid method names to run individual methods">
		<cfargument name="TestRunKey" type="string" required="true" hint="the key returned from startTestRun; used for managing the pool of components">
		<cfset var s_results = StructNew()>
		<cfset var key = "">
		<cfset var suite = createObject("component","TestSuite")>
		<cfset var testResult = "">
		
		<cfset var obj = getObject(componentName,TestRunKey)>
		<cfset var componentPath = getMetadata(obj).path>
		
		<cfset actOnTestCase(obj)>
		
		<cfif len(methodNames)>
			<cfset suite.add(componentName, methodNames, obj)>
		 <cfelse>			
			<cfset suite.addAll(componentName, obj)> 
		</cfif>
		
		<cfset testResult = suite.run()>
		
		
		<cfset s_results = testResultToStructs(testResult, componentPath)>
		<cfreturn s_results>
	</cffunction>

	<cffunction name="getComponentMethods" access="remote" returntype="array">
		<cfargument name="ComponentName" required="true" type="string" hint="">
		<cfset var methods = ArrayNew(1)>
		<cfset var obj = "">
		<!--- by doing this instead of letting it throw an error
		we ensure that the error (most likely a parse error)
		continues to show up when they run the test.  --->
		<cftry>
			<cfset obj = createObject("component",ComponentName)>
			<cfset methods = obj.getRunnableMethods()>
		<cfcatch>
			<cfset ArrayAppend(methods,listLast(arguments.ComponentName,"."))>
		</cfcatch>
		</cftry>	
		
		<cfreturn methods>
	</cffunction>
	
	<cffunction name="actOnTestCase" access="public" hint="an 'Interceptor' for custom remote facades. This will enable you to act on each test case object, possibly injecting additional data, etc" output="false">
		<cfargument name="testCase" required="true" hint="">
		
	</cffunction>
	
	<cffunction name="testResultToStructs" hint="turns the TestResult item into a struct for passing to eclipse. It will only ever process a single component under test, although I did build it to loop over the array of tests returned from the TestResult, although currently there is no condition under which that will ever be more than a single-element array" access="public">
		<cfargument name="TestResult" required="true">
		<cfargument name="ComponentPath" required="true" hint="the full filesystem path to the component under test">
		
		<cfset var s_results = StructNew()>
		<cfset var a_tests = TestResult.Results>
		<cfset var s_test = StructNew()>
		<cfset var test = 1>
		<cfset var tag = 1>
		<cfset var i = 1>
		<cfset var t = "">
		<cfset var debugString = "">		
		<cfset var isFrameworkTest = cu.isFrameworkTemplate(ComponentPath)>
		
		<cfloop from="1" to="#ArrayLen(a_tests)#" index="test">	
			<cfset s_test = a_tests[test]>
			<cfif not StructKeyExists(s_results,s_test.component)>
				<cfset s_results[s_test.component] = StructNew()>
			</cfif>
			<cfset s_results[s_test.component][s_test.TestName] = StructNew()>
			<cfset t = s_results[s_test.component][s_test.TestName]>
			
			<cfif ArrayLen(s_test.debug)>
				<cfsavecontent variable="debugString">
				<cfdump var="#s_test.debug#" label="cumulative debug() calls">
				</cfsavecontent>
			<cfelse>
				<cfset debugString = " No calls made to debug(). ">
			</cfif>			
			
			<cfset t.OUTPUT = s_test.content & debugString>
			<cfset t.MESSAGE = "">
			<cfset t.RESULT = s_test.TestStatus>
			<!--- <cfset t.httprequestdata = getHTTPRequestData()> --->
			<cfif not isSimpleValue(s_test.error)>
				<cfset t.EXCEPTION = formatExceptionKey(s_test.error.type)>
				<cfset t.MESSAGE = s_test.error.message>
				<cfif len(s_test.error.detail)>
					<cfset t.MESSAGE = t.MESSAGE & " " & s_test.error.detail>
				</cfif>
				<!--- <cfset t.TagContext = s_test.error.tagcontext>	 --->
				<cfset t.TAGCONTEXT = ArrayNew(1)>		
				<cfset i = 1>	
					<!---		 --->	
				<cfloop from="1" to="#ArrayLen(s_test.error.tagcontext)#" index="tag">
					<cfif FileExists(s_test.error.tagcontext[tag].template)>
						<cfif isFrameworkTest OR NOT cu.isFrameworkTemplate(s_test.error.tagcontext[tag].template)>
							<cfset t.TAGCONTEXT[i] = StructNew()>
							<cfset t.TAGCONTEXT[i].FILE = s_test.error.tagcontext[tag].template>
							<cfset t.TAGCONTEXT[i].LINE = s_test.error.tagcontext[tag].line>
							<cfset i = i + 1>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
		</cfloop>
		
		<cfreturn s_results>
	</cffunction>
	
	<cffunction name="formatExceptionKey" access="package" hint="ensures a string in the EXCEPTION key. This is necessitated by a weirdo bug in CF with NonArrayExceptions" returntype="string">
		<cfargument name="ErrorType" required="true" type="any" hint="the TYPE key from the cfcatch struct">
		
		<cfif isSimpleValue(ErrorType)>
			<cfreturn ErrorType>
		<cfelse>
			<cfreturn "Exception[ComplexValue]: " & ErrorType.toString()>
		</cfif>
	</cffunction>

</cfcomponent>