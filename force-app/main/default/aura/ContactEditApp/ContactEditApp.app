<aura:application extends="force:slds">
    <aura:attribute name="recId" type="String" />
    <aura:attribute name="message" type="String" />
    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />
    
    <c:canvasSubscriber/>
    
    <c:contactEditScreen onfilterchange="{!c.eventcall}"/>
    
    <div class="slds-grid">
        <div class="slds-col">
            <lightning:recordEditForm
                                      onsuccess="{!c.handleSuccess}"
                                      recordId="{!v.recId}"
                                      objectApiName="Contact">
                <lightning:messages />
                <lightning:inputField fieldName="Name" />
                <div class="slds-m-top_medium">
                    <lightning:button variant="brand" type="submit" name="save" label="Save" />
                </div>
            </lightning:recordEditForm>
        </div>
    </div>
</aura:application>