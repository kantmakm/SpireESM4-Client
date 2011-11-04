<cfif variables.ratings.recordcount>
	<cfoutput query="variables.ratings">
		<div class="rating">
            <div class="#lcase(variables.ratings.tiname)#_rating" style="float:left;color:##4f4823">
            	<strong>#variables.ratings.rating#</strong>
            </div>
            <div style="margin-left:75px;color:##4f4823;">
                <strong>#ucase(variables.ratings.tidescription)#:</strong> #rereplace(variables.ratings.ratingtext,"<[^<>]+>","")#
            </div>
            <br class="clear"/>
		</div>
	</cfoutput>
<cfelse>
	<div>There are currently no ratings on this product.</div>
</cfif>
