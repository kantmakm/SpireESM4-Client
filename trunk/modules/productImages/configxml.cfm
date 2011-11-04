<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^system/productimages/scanfolder/?$">
		<loadcfc>scanfolder</loadcfc>
	</action>
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>