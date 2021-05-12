({
    // this function automatic call by aura:waiting event  
    getQRCodeHelper : function(component, event, helper) {
        var compEvent = component.getEvent("MFAScreenEvent");
        var action = component.get("c.getQRCode");
        
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();  
            compEvent.setParams(
                {
                    IdentitySelectionScreen : false,
                    IdentityConfirmationScreen : true,
                    selectedIdentity : component.get("v.selectedIdentity"),
                    qrWrapper : rtnValue  
                }
            );
            compEvent.fire();
            helper.hideSpinner(component, event, helper);
        });
        
        $A.enqueueAction(action);
    },
    
    sendEmailWithSecurityCode : function(component, event, helper) {
        var compEvent = component.getEvent("MFAScreenEvent");
        var action = component.get("c.sendEmailWithSecurityCode");
        action.setParams(
            {
                byPassFlag : false    
            }
        );
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();  
            compEvent.setParams(
                {
                    IdentitySelectionScreen : false,
                    IdentityConfirmationScreen : true,
                    selectedIdentity : component.get("v.selectedIdentity")
                }
            );
            compEvent.fire();
            helper.hideSpinner(component, event, helper);
        });
        
        $A.enqueueAction(action);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.spinner", true); 
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.spinner", false);
    }
})