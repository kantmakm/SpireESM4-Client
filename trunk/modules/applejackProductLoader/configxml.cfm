<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^system/productload/?$">
		<loadcfc>productLoader</loadcfc>
	</action>
	<action match="^system/productload/grapes/?$">
		<loadcfc>productLoaderForGrapes</loadcfc>
	</action>
	<!--->
	<action match="^cart?$">
		<loadcfc>cartList</loadcfc>
		<template>Interior1Column</template>
		<title>Your Cart</title>
		<pagename>Cart</pagename>
		<description>Cart</description>
		<keywords>Cart</keywords>
	</action>--->
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>