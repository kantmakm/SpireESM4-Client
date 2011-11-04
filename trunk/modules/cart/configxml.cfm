<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^cart/add/?$">
		<loadcfc>addToCart</loadcfc>
	</action>
	<action match="^cart/update/?$">
		<loadcfc>cartUpdate</loadcfc>
	</action>
	<action match="^cart/?$">
		<loadcfc>cartList</loadcfc>
		<template>Interior1Column</template>
		<title>Your Cart</title>
		<pagename>Cart</pagename>
		<description>Cart</description>
		<keywords>Cart</keywords>
	</action>
	
	<action match="^cart/billingdelivery/?$">
		<loadcfc>checkoutbillingdeliveryForm</loadcfc>
		<template>Interior1Column</template>
		<title>Checkout Step 1 - Billing and Shipping - Delivery Address</title>
		<pagename>Billing &amp; Shipping / Delivery Address</pagename>
		<description>Billing Shipping / Delivery Address</description>
		<keywords>Billing  Shipping / Delivery Address</keywords>
	</action>
	
	<action match="^cart/shippingpayment/?$">
		<loadcfc>checkoutShippingPaymentForm</loadcfc>
		<template>Interior1Column</template>
		<title>Checkout Step 2 - Shipping Delivery and Payment Options</title>
		<pagename>Shipping/Delivery &amp; Payment Options</pagename>
		<description>Shipping/Delivery &amp; Payment Options</description>
		<keywords>Shipping/Delivery &amp; Payment Options</keywords>
	</action>
	
	<action match="^cart/orderconfirmation/?$">
		<loadcfc>checkoutOrderConfirmationForm</loadcfc>
		<template>Interior1Column</template>
		<title>Checkout Step 3 - Order Validation</title>
		<pagename>Validate Order</pagename>
		<description>Validate Order</description>
		<keywords>Validate Order</keywords>
	</action>
	
	<action match="^cart/ordercomplete/?$">
		<loadcfc>checkoutOrderComplete</loadcfc>
		<template>Interior1Column</template>
		<title>Checkout Step 4 - Order Confirmed</title>
		<pagename>Order Complete</pagename>
		<description>Order Complete</description>
		<keywords>Order Complete</keywords>
	</action>
	
	<action match="^cart/lineitems/?$">
		<loadcfc>cartlineitems</loadcfc>
	</action>
</moduleInfo>
</cfsavecontent>

<!--- <template>Interior2Column</template>
		<title>Product Catalog</title>
		<pagename>Product Catalog</pagename>
		<description>Product Catalog</description>
		<keywords>Product Catalog</keywords> --->
<cfset modulexml = xmlparse(modulexml)>