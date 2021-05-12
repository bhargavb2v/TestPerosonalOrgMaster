({
	doInit : function(component, event, helper) {
		var myPageRef = component.get("v.pageReference");
		var id = myPageRef && myPageRef.state ? myPageRef.state.recordId : ""; 
 

		var action = component.get("c.getContact");
        if(id){
            action.setParams({ conId:id});
        }
        else{
        	action.setParams({ conId:component.get("v.recordId") });
        }
        
        component.set("v.conId", id);

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.conObj",response.getReturnValue());
            }
            else{
                // do something
            }
        });
        $A.enqueueAction(action);

	},
    handleApplicationEvent : function(cmp, event) {
        var message = event.getParam("message");

        // set the handler attributes based on event data
        cmp.set("v.messageFromEvent", message);
        var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        cmp.set("v.numEvents", numEventsHandled);
        cmp.set("v.conId", event.getParam("conId"));
    }
})