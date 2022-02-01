<aura:application extends="force:slds" access="global">
	<aura:handler name="init" value="{!this}" action="{!c.doInit}"/>    
    <div aura:id="content">{!v.body}</div>
</aura:application>