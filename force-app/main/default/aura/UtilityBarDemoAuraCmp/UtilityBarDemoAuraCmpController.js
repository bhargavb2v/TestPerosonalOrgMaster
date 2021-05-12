({
    eventCall : function(component, event , helper){
        console.log('Test call');
        var filters = event.getParam('filters');
        console.log(filters);
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.openTab({
            pageReference: {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId":filters.Id,
                    "actionName":"view"
                },
                "state": {}
            },
            focus: true
        }).catch(function(error) {
            console.log(error);
        });
    },
    
    openTab : function(component, event, helper) {
        helper.openTabHelper(component, event, helper);
},
    fireApplicationEvent : function(cmp, event,helper) {
        helper.fireApplicationEventHandler(cmp, event,helper);
    },
        saveContact : function(cmp, event,helper) {
            var action = cmp.get("c.saveContactData");
            
            action.setParams({ 
                firstName:cmp.get("v.firstName"),
                lastName: cmp.get("v.lastName")
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.conId",response.getReturnValue());
                    //helper.fireApplicationEventHandler(cmp, event,helper);
                    helper.openTabHelper(cmp, event, helper);
                }
                else{
                    // do something
                }
            });
            $A.enqueueAction(action);
        }
})