
<input type="button" onclick="location.href='/cart/print';" name="action" value="Print Shopping List">
<input type="submit" name="action" value="Update Cart">
<input type="submit" name="action" value="Resume Shopping">
<input type="submit" name="action" value="Checkout">

<cfoutput>#variables.cartItemsTableObj.showHTML()#</cfoutput>

<!---
<table class="cart_subtotals">
	<tbody>
		<tr>
			<td>
				Subtotal:
			</td>
			<td>$#lcl.cart.subTotal#</td>
		</tr>
		<tr>
			<td>
				A total Sale Price Savings of :
			</td>
			<td>
				$#lcl.cart.savings_total#
			</td>
		</tr>
		<tr>
			<td>
				With an Advantage Card your total would be
			</td>
			<td>
				$#lcl.ac_savings_total#
			</td>
		</tr>
		<tr>
			<td>
				An additional Savings of : $#lcl.ac_savings_total#
			</td>
			<td>
				$#lcl.ac_savings_total#
			</td>
		</tr>
		<tr>
			<td colspan="2">
				Login to our Applejack Account or Create an Account and Save TODAY
			</td>
		</tr>
	</tbody>
</table>--->

<p>Substitution Options : <select name="substitute"><option></option></select><br>Applejack will ....</p>

<p>RULES GO HERE</p>
</form>