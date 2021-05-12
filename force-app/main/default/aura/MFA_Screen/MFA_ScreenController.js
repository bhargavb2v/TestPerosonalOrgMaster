({
	doInit : function(component, event, helper) { 
		helper.doInitHelper(component, event, helper);
    },
    
    handleScreenEvent : function(component, event, helper) {
        component.set("v.IdentitySelectionScreen",event.getParam("IdentitySelectionScreen"));
        component.set("v.IdentityConfirmationScreen",event.getParam("IdentityConfirmationScreen"));
        component.set("v.selectedIdentity",event.getParam("selectedIdentity"));
        component.set("v.qrWrapper",event.getParam("qrWrapper"));
	}
})