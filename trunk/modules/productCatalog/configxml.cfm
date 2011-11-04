<cfsavecontent variable="modulexml">
<moduleInfo searchable="1">
	<action match="^(wine|spirits|beer|cordials-liqueurs)/product/[a-zA-Z0-9\-]+/$">
		<loadcfc>productView</loadcfc>
		<template>Interior2Column</template>
		<title>Product Item</title>
		<pagename>Product Item</pagename>
		<description>Product Item</description>
		<keywords>Product Item</keywords>
	</action>
	
	<action match="^(wine|spirits|beer|cordials-liqueurs)/catalogsearch/">
		<loadcfc>productSearch</loadcfc>
		<template>_productSearch</template>
		<title>Product Catalog</title>
		<pagename>Product Catalog</pagename>
		<description>Product Catalog</description>
		<keywords>Product Catalog</keywords>
	</action>	
	
	<action match="^(wine|spirits|beer|cordials-liqueurs)/catalog/">
		<loadcfc>productCatalog</loadcfc>
		<template>Interior2Column</template>
		<title>Product Catalog</title>
		<pagename>Product Catalog</pagename>
		<description>Product Catalog</description>
		<keywords>Product Catalog</keywords>
	</action>
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>