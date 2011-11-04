<cfset lcl.fp = listfirst(requestObject.getFormUrlVar('path'),"/")>
<!-- nosearch -->
<form id="myForm">
<cfoutput query="variables.taxonomylist" group="taxonomymenuitemid">
	<cfsilent>
		<cfset lcl.nonfavorites = 0>
		<cfoutput>
			<cfif NOT favorite>
				<cfset lcl.nonfavorites = lcl.nonfavorites + 1>
			</cfif>
		</cfoutput>
	</cfsilent>
	<div id="#taxonomyid#" class="taxonomy_group">
	<h5>Shop by #taxonomyname#</h5>
	<ul>
	<cfoutput>
		<cfif favorite>
			<li><input type="checkbox" name="by_#taxonomyid#" id="#taxonomyitemid#" value="#safename#" >&nbsp&nbsp#taxonomyitemname#</li>
		</cfif>
	</cfoutput>
	</ul>
	
	<cfif lcl.nonfavorites>
		<a href="/taxonoallmenu/?view=more&menuitemid=#taxonomymenuitemid#&linkpath=#urlencodedformat("#lcl.fp#/catalog/by_#taxonomyid#")#" class="morelink">More &raquo;</a>
	</cfif>
	</div>
</cfoutput>
<form>

<style>
	.taxonomyPopup{
		border:1px solid gray;
		background:white;
		padding:20px;
		position:absolute;
		display:none;
	}
	.taxonomyPopup td{
		padding:3px;
	}
	.taxonomyPopupCloseLink {
		border:1px solid gray;
		background:white;
		padding:5px 10px;
		margin-top:5px
	}
</style>
<script type="application/javascript">
	jQuery(document).ready (function() {

		jQuery(':checkbox').click(function(){
			
			var divStr = jQuery('#myForm').serialize();
			
			<cfoutput>
			jQuery.get("/#lcl.fp#/catalogsearch/?"+encodeURI(divStr.toString()), function(data){
				var div = jQuery(".c2");
					div.html(data);
					div.show("fast");
			});
			</cfoutput>
		});

		jQuery("a.morelink").click(function(e){
			e.preventDefault();
			$l = jQuery(this);
			jQuery.get($l.attr("href"), function(data){
				var div = $l.parent("div.taxonomy_group");
					div.html(data);
					div.show("fast");
				return false
			});
		});
	});
</script>
<!-- /nosearch -->