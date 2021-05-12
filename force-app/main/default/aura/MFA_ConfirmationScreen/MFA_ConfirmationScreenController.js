({
    init : function(component, event, helper) { 
        helper.initHelper(component, event, helper);
    },
    
    backButtonClick : function(component, event, helper) {
        var compEvent = component.getEvent("MFAScreenEvent");
        compEvent.setParams(
            {
                IdentitySelectionScreen : true,
                IdentityConfirmationScreen : false,
                selectedIdentity : component.get("v.selectedIdentity")
            }
        );
        compEvent.fire();
    },
    
    submitButtonClick : function(component, event, helper) {
        helper.submitButtonClickHelper(component, event, helper);
    },
    
    newVerificationCodeClick: function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        helper.sendEmailWithSecurityCode(component, event, helper);
    },
})