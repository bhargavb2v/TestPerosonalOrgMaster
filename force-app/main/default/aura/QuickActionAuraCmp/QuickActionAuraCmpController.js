({
    myAction : function(component, event, helper) {
        
    },
    navigateCmp: function(component, event , helper){
        console.log('Test call');
        var filters = event.getParam('filters');
        console.log(filters);
        //component.set('v.message', filters.length > 0 ? 'Your selection: ' + filters.join() : 'No selection');
        
        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__component",
            "attributes": {
                "componentName": "c__ContactEditApp"
            }, 
            "state": {
                'message':'This is the target page'
            }
        };
        navService.navigate(pageReference);
    }
})