({
    initHelper : function(component, event, helper){
        helper.Mask_EmailAddress(component, event, helper);
    },
    
    NavigationFlow : function(component, event, helper) {
        // When an option is selected, navigate to the next screen
        var navigate = component.get("v.navigateFlow");
        navigate("NEXT");
    },
    
    Mask_EmailAddress:function(component, event, helper) {
        var mfaSettings = component.get("v.MFASettings");
        var emailHeaderMessage = mfaSettings.Email_Confirmation_Screen_Message__c;
        var userIdentity = component.get("v.userIdentity");
        var userEmail = userIdentity.userEmail; 
        
        var email_address, email_address_Prefix, masked = '';
        var email_masked;    
        email_address = userEmail.split("@");
        email_address_Prefix = email_address[0];
        
        for(var i=0; i < email_address_Prefix.length; i++){
            if(i < 3) {   
                masked = masked + email_address_Prefix[i].toString();
            }
            else {
                masked = masked + "*";
            }
        }
        
        email_masked = masked+'@'+email_address[1];
        
        emailHeaderMessage = emailHeaderMessage.replace("<USER_EMAIL>", email_masked);
        
        var isNewCode = component.get("v.isNewCode");
        if(isNewCode){
        	emailHeaderMessage = emailHeaderMessage.replace("<VERIFICATION CODE>", "new verification code");
        }
        else{
        	emailHeaderMessage = emailHeaderMessage.replace("<VERIFICATION CODE>", "verification code");    
        }
        
        component.set("v.emailHeaderMessage", emailHeaderMessage);
    },
    
    submitButtonClickHelper : function(component, event, helper) {
        var selectedIdentity = component.get("v.selectedIdentity");
        var userIdentity = component.get("v.userIdentity");
        var qrWrapper = component.get("v.qrWrapper");
        var action;
        if(selectedIdentity == 'Email'){
            action = component.get("c.validateSecurityCode");
            action.setParams({  
                securityCode : component.get("v.securityCode")    
            });
        }
        else if(selectedIdentity == 'Mobile'){
            action = component.get("c.validateTOTP"); 
            action.setParams({  
            	regToken : component.get("v.regToken"),
                secretKey : qrWrapper.secretKey,
                token : component.get("v.token")    
            });
        }

        helper.showSpinner(component, event, helper);
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if(rtnValue){
               	component.set("v.errorFlag",false);
                var mfaAppEvent = $A.get("e.c:MFA_AppEvent");
                mfaAppEvent.setParams(
                    {"finshFlow":true}
                );
                mfaAppEvent.fire();
            }
            else{
            	component.set("v.errorFlag",true);    
            }
            
            helper.hideSpinner(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    sendEmailWithSecurityCode : function(component, event, helper) {
        var action = component.get("c.sendEmailWithSecurityCode");
        action.setParams(
            {
                byPassFlag : true    
            }
        );
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();  
            component.set("v.isNewCode",rtnValue);
            component.set("v.errorFlag",false);
            helper.Mask_EmailAddress(component, event, helper);
            
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