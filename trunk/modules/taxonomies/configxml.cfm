<cfsavecontent variable="modulexml">
<moduleInfo>
	<action match="^taxonomymenu/?$">
        <loadcfc>moreMenu</loadcfc>
        <template>_blank</template>
    </action>
	<action match="^taxonoallmenu/?$">
        <loadcfc>allMenu</loadcfc>
        <template>_blank</template>
    </action>	
</moduleInfo>
</cfsavecontent>

<cfset modulexml = xmlparse(modulexml)>