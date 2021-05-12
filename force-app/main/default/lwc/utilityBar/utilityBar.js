import { LightningElement } from 'lwc';

export default class UtilityBar extends LightningElement {
    //@track val1;
    ClickHere(event){
        var recId = '0036F000022ViRMQA0';
        var compName = 'test';
        //console.log(val);

        let filters = {'Id':recId,'compName':compName};
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: {filters:filters}
        });
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }
}