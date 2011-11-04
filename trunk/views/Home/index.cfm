<cfoutput>
<cfcontent reset="true"><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"><!-- home -->
<cfinclude template="../headtag.cfm"/>

<body class="home">
	<div id="outercontainer">
		<div id="innercontainer">
			<!-- header -->
			<div class="header">
				<cfinclude template="../header.cfm">
				<div class="nav">#showContentObject('dhtmlNav', 'Navigation', 'moduleaction=flatnav')#</div>
			</div>
			<!-- /header -->
			<div id="bodyContent">
				<cfinclude template="../bodyheader.cfm">
				<cfif  contentObjectNotEmpty('item_above_cols')>
					#showContentObject('item_above_cols', 'HTMLContent,TextContent', 'editable')#
				</cfif>
				<div class="c1">
					<div class="content">
					[postprocess-userflash]

					<cfif  contentObjectNotEmpty('middleItem_1_Content')>
						#showContentObject('middleItem_1_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('middleItem_2_Content')>
						#showContentObject('middleItem_2_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('middleItem_3_Content')>
						#showContentObject('middleItem_3_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('middleItem_4_Content')>
						#showContentObject('middleItem_4_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('middleItem_5_Content')>
						#showContentObject('middleItem_5_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>
					
					<cfif contentObjectNotEmpty('middleItem_6_Content')>
						#showContentObject('middleItem_6_Content', 'HTMLContent,Assets,dhtmlPager,Events,Forms,News,ProductCatalog,SiteMaps,TextContent,Videos,MultiSpot,assetImages,imageRotator', 'editable')#
					</cfif>
					<!--- important! --->&nbsp;
					</div>
				</div>
				<div class="c2">
					<div class="content">
					<cfif contentObjectNotEmpty('rightItem_1_Content')>
						#showContentObject('rightItem_1_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('rightItem_2_Content')>
						#showContentObject('rightItem_2_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('rightItem_3_Content')>
						#showContentObject('rightItem_3_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('rightItem_4_Content')>
						#showContentObject('rightItem_4_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('rightItem_5_Content')>
						#showContentObject('rightItem_5_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>

					<cfif contentObjectNotEmpty('rightItem_6_Content')>
						#showContentObject('rightItem_6_Content', 'HTMLContent,Assets,Events,News,ProductCatalog,TextContent,assetImages,Forms', 'editable')#
					</cfif>
					</div>
				</div>
				<br class="clear"/>
			</div>

			<!-- footer -->
            <div class="foot"></div>
			<cfinclude template="../footer.cfm">
			<!-- /footer -->
		</div>
	</div>
</body>
</html>
</cfoutput>