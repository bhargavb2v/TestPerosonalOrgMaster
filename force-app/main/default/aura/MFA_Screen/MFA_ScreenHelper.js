({
    doInitHelper : function(component, event, helper){
        var resultJson = component.get("v.resultWrapper");
        var result = JSON.parse(resultJson);
        if(result != null){
            component.set("v.userIdentity",result.userIdentity);
            component.set("v.MFASettings",result.mfaSettings);
        }
        
        component.set("v.IdentitySelectionScreen",true);
    },
})