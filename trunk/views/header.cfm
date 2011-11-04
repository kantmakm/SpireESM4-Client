<cfoutput>
			<!-- nosearch -->
				<div class="headerleft">
					<a href="/" tabindex="1" title="Home"><img src="/ui/images/Applejack-logo.gif" alt="Home" /></a>
				</div>
				<div class="utilitynav">
					<ul>
						<!---<li><a href="/Advantage-Card/Advantage-Card-Application/" title="">Advantage Card - Email Specials</a></li>--->
						<li><a href="/cart" title="">Shopping Cart</a></li>
						<li>[postprocess-usershtml]</li>
					</ul>
					<div class="search">
						<form action="/search/">
							<div id="srchcrit" class="left">
								<input type="text" name="criteria" value="Search Applejack" id="searchCriteria"/>
								<select name="product_category" id="searchCriteriaSel" style="width:100px">
									<option value="wine,spirits,beer,cordials_liqueurs">ENTIRE SITE</option>
									<option value="wine">Wine</option>
									<option value="spirits">Spirits</option>
									<option value="beer">Beer</option>
									<option value="cordials_liqueurs">Cordials & Liqueurs</option>
								</select>
								
							</div>
							<div id="srchbtn"><input type="image" class="img noborder" src="/ui/images/searchbtn.png" alt="Search Applejack" /></div>
						</form>
					</div>
					<script type="text/javascript">
						jQuery(function(){
							jQuery("##srchcrit ##searchCriteria")
								.click(function(){if (jQuery(this).val() == "Search Applejack") jQuery(this).val("");})
								.blur(function(){if (jQuery(this).val() == "") jQuery(this).val("Search Applejack");})
						});
					</script>
				</div>
				<br class="clear"/>
			<!-- /nosearch -->
</cfoutput>