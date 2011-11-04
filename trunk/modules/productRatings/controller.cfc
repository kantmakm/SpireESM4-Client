<cfcomponent extends="resources.abstractController" ouput="false">
	
	<cffunction name="ratingsforproductview">
		<cfset var productRatingsModel = createObject("component","modules.productRatings.models.productRatings").init(requestObject)>
		<cfset productRatingsModel.setRatedObj(variables.data.productObj)>
		<cfset variables.ratings = productRatingsModel.getRatings()>
		<cfset variables.title = "All Product Ratings<hr class='fullwidthdottedhrwithmargins'>">
		<cfreturn this>
	</cffunction>
	
</cfcomponent>