<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^cart/printlist/?$">
		<loadcfc>cartPrint</loadcfc>
		<template>_print</template>
		<title>Print Your Cart</title>
		<pagename>Print Cart</pagename>
		<description>Cart</description>
		<keywords>Cart</keywords>
	</action>
</moduleInfo>
</cfsavecontent>

<!--- <template>Interior2Column</template>
		<title>Product Catalog</title>
		<pagename>Product Catalog</pagename>
		<description>Product Catalog</description>
		<keywords>Product Catalog</keywords> --->
<cfset modulexml = xmlparse(modulexml)>