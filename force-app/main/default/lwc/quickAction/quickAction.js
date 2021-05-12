import { LightningElement, wire, track,api } from 'lwc';  
import { NavigationMixin } from 'lightning/navigation';
import getButtons from '@salesforce/apex/QuickActionController.getButtons';

export default class QuickAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @track actionList;

    connectedCallback(){
        console.log(this.recordId);
        this.loadData();
    }

    loadData(){
        getButtons({})
        .then(result => {
            console.log(result);
            this.actionList = result;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    //@track val1;
    navigateToComp(event){
        var recId = event.target.getAttribute("data-id");
        var compName = event.target.getAttribute("data-name");
        //console.log(val);

        let filters = {'Id':recId,'compName':compName};
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: {filters:filters}
        });
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }
}