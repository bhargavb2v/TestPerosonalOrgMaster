({
	doInit : function(component, event, helper) {
		// the function that reads the url parameters
            var getUrlParameter = function getUrlParameter(sParam) {
                var sPageURL = decodeURIComponent(window.location.search.substring(1)),
                    sURLVariables = sPageURL.split('&'),
                    sParameterName,
                    i;

                for (i = 0; i < sURLVariables.length; i++) {
                    sParameterName = sURLVariables[i].split('=');

                    if (sParameterName[0] === sParam) {
                        return sParameterName[1] === undefined ? true : sParameterName[1];
                    }
                }
            };
        let id = getUrlParameter('id');
        if(id){
            component.set("v.recId",id);
        }
        console.log(component.get("v.recId"));
	},
    
    addListeners : function (component){
      var cmp = component.find("fullCmp");
      cmp.forEach(function(item){
    
          item.getElement().addEventListener("click", function(){
            alert('Hello World');
          });
      });        
    },
    handleSuccess: function(component, event , helper){
    	console.log("handleSuccess");
        //window.opener.ProcessMethod('Message to the parent');
	},
  
    eventcall: function(component, event , helper){
        console.log('Test call');
    	var filters = event.getParam('filters');
        component.set('v.message', filters.length > 0 ? 'Your selection: ' + filters.join() : 'No selection');
	}
})