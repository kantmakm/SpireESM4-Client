<cfcomponent extends="resources.abstractController" ouput="false">

	<cffunction name="myhistory">
		<cfset var uo = requestObject.getUserObject()>
		<cfset var lcl = structnew()>
		
		<cfset variables.ordersModel = createObject("component","modules.orders.models.orders").init(requestObject)>
		<cfset lcl.sortobj = structnew()>
		<cfset lcl.sortobj.sort = "created DESC">
		<cfset variables.orders = variables.ordersModel.getByUserId(uo.getUserId(), lcl.sortobj)>

		<cfset lcl.tbl = createObject("component", "utilities.table").init(requestObject)>
		<cfset lcl.tbl.setName("myorders")>
		<cfset lcl.tbl.setHeader("<h2>Previous Orders</h2>")>
		<cfset lcl.tbl.setNoRecordsMessage("You do not have any previous orders.")>
		<cfset lcl.cols = lcl.tbl.getColumns()>
		<cfset lcl.tblatts = structnew()>
		<cfset lcl.tblatts['class'] = 'cart fancytable'>
		
		<cfset lcl.tblformats = structnew()>
		<cfset lcl.tblformats['price'] = 'money'>
		<cfset lcl.tblformats['created'] = 'date'>
        <cfset lcl.tblformats['ordertotal'] = 'money'>

		<cfset lcl.tbl.setformats(lcl.tblformats)>

		<cfset lcl.tbl.setTableAttributes(lcl.tblatts)>	
		
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Purchase Date">
		<cfset lcl.tmp.field = "created">
		<cfset arrayappend(lcl.cols, lcl.tmp)>
		
   		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Order Status">
		<cfset lcl.tmp.field = "orderstatus">  
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>
        
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Order No.">
		<cfset lcl.tmp.field = "id">
		<cfset lcl.tmp.format = "<a href=""/user/previousorder/[id]"" style='width:20%;'>Click To View</a>">
		<cfset arrayappend(lcl.cols, lcl.tmp)>
        
   		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "center">
		<cfset lcl.tmp.title = "Items Total">
		<cfset lcl.tmp.field = "itemsTotal">
		<cfset arrayappend(lcl.cols, lcl.tmp)>	
        
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Order Total">
		<cfset lcl.tmp.field = "ordertotal">  
		<cfset arrayappend(lcl.cols, lcl.tmp)>	

<!---		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Advantage Card Savings">
		<cfset lcl.tmp.field = "advantagesavings">  
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>--->

		<cfset lcl.tbl.setColumns(lcl.cols)>
		<cfset lcl.tbl.setData(variables.orders)>
		
		<cfset variables.table = lcl.tbl>
		
		<cfreturn lcl.tbl>
	</cffunction>
	
</cfcomponent>