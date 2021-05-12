({
    helperMethod : function() {
        
    },
    fireApplicationEventHandler : function(cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        var appEvent = $A.get("e.c:ApplicationEventDemo");
        appEvent.setParams({
            "message" : "An application event fired from utility bar.",
            "conId":cmp.get("v.conId")});
        appEvent.fire();
    },
    
    openTabHelper : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__ContactEditCmp"  // c__<comp Name>
                },
                "state": {
                    "recordId": component.get("v.conId"),
                }
            },
            focus: true
        }).then((response) => {
            workspaceAPI.setTabLabel({
            tabId: response,
            label: "ContactEdit Screen"
        });
    }).catch(function(error) {
    console.log(error);
});
},
})