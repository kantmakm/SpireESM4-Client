<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^user/previousorder/[A-Z0-9\-]{35}/?$">
		<loadcfc>prevOrder</loadcfc>
		<template>Interior1Column</template>
		<title>Order Summary</title>
		<pagename>Order Summary</pagename>
		<description>Order Summary</description>
		<keywords>Order Summary</keywords>
	</action>
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>