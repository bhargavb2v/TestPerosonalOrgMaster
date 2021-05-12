import { LightningElement, wire, track,api } from 'lwc';  
import getContact from '@salesforce/apex/LWCCreateContactController.getContact';
import saveContact from '@salesforce/apex/LWCCreateContactController.saveContact';

export default class ContactEditScreen extends LightningElement {
    @api recordId;
    @track error;
    @api contact ;
    @track conObj = {};
    @track showModaFlag=false;
    @track conFirstName;
    @track conLastName;

    firstnameChange(event){
        //let data = this.contact;
       // data['FirstName'] = event.target.value;
        //this.contact['FirstName'] = event.target.value;
        this.conFirstName = event.target.value;
        
    }
    lastnameChange(event){
       // this.contact['LastName'] = event.target.value;
       this.conLastName = event.target.value;
    }

    updateContact() {    
        /*this.conObj.FirstName = this.conFirstName;
        this.conObj.LastName = this.conLastName;
        this.conObj.Id = this.recordId;
        console.log(this.conObj.FirstName);
        console.log(this.conObj.LastName);

        saveContact({objContact: this.conObj})
        .then(result => {
            console.log(JSON.stringify(result));
            this.contact = result;
            console.log(this.contact.Name);
            this.showModaFlag=false;
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })*/
        window.opener.ProcessChildMessage('Message to the parent');
        this.testMethod();
    }

    testMethod() {
        const filters = {'key':'ram'};
        const filterChangeEvent = new CustomEvent('filterchange', {
            detail: filters,
        });
        // Fire the custom event
        this.dispatchEvent(filterChangeEvent);
    }
}