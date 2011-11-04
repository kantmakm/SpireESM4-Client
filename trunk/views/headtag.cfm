<head>
	<cfoutput>
	<title>#variables.pageinfo.title#</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

    <meta name="description" content="#variables.pageinfo.description#" />
	<meta name="keywords" content="#variables.pageinfo.keywords#" />

	<link rel="stylesheet" href="/ui/css/layout.css" type="text/css" />
	<link rel="stylesheet" href="/ui/css/typo.css" type="text/css" />
	<link rel="stylesheet" href="/ui/css/nav.css" type="text/css" />
	<link rel="stylesheet" href="/ui/css/form.css" type="text/css" />
	<link rel="stylesheet" href="/ui/css/print.css" type="text/css" media="print" />
	<link rel="stylesheet" href="/ui/css/widgets.css" type="text/css"/>
	<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />

	<script type="text/javascript" src="/ui/js/jquery-1.3.2.min.js"></script>
	<script>jQuery.noConflict();</script>
	<script type="text/javascript" src="/ui/js/jquery-ui-1.7.1.min.js"></script>
	<script type="text/javascript" src="/ui/js/jquery.allpages.js"></script>

	#this.getHeaderItems()#
	</cfoutput>
</head>