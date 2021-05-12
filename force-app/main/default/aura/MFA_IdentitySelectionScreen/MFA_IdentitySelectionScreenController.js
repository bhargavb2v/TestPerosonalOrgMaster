({
    doInit : function(component, event, helper) {
        var IdentityOptions = [];
        var userIdentity = component.get("v.userIdentity");
        var option1Label = 'Send an email to me at '+userIdentity.userEmail;
        var option1Value = 'Email';
        var option1 = {'label': option1Label , 'value': option1Value};
        IdentityOptions.push(option1);
        var option2Label = 'Use a mobile authenticator app for user '+userIdentity.userName;
        var option2Value = 'Mobile';
        var option2 = {'label': option2Label , 'value': option2Value};
        IdentityOptions.push(option2);
        
        component.set("v.IdentityOptions",IdentityOptions);
    },
    
    continueClick : function(component, event, helper) {
        var selectedIdentity = component.get("v.selectedIdentity");
        var action;
        helper.showSpinner(component, event, helper);
        if(selectedIdentity == 'Email'){
        	helper.sendEmailWithSecurityCode(component, event, helper);    
        }
        else if(selectedIdentity == 'Mobile'){
            helper.getQRCodeHelper(component, event, helper);
        }
        
        
        /*var myEvent = $A.get("e.c:MFAScreenEvent");
        myEvent.setParams(
            {"data":"Test"}
        );
        myEvent.fire();*/
    }
})