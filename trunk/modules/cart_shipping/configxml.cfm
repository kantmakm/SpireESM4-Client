<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^system/discovershippingmodules/?$">
		<loadcfc>discoverShippingMethods</loadcfc>
	</action>
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>