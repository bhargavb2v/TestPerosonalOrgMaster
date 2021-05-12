/* eslint-disable no-console */
import { LightningElement, wire, track,api } from 'lwc';  
import getContact from '@salesforce/apex/LWCCreateContactController.getContact';
import saveContact from '@salesforce/apex/LWCCreateContactController.saveContact';

export default class LwcContactDemoController extends LightningElement {
    @api recordId;
    @track error;
    @api contact ;
    @track conObj = {};
    @track showModaFlag=false;
    @track conFirstName;
    @track conLastName;

    // @wire(getContact, { conId: '$recordId'})
    // wiredOpps({
    //     error,
    //     data
    // }) {
    //     if (data) {
    //         this.contact = data;
    //         console.log(data);
    //         console.log(JSON.stringify(data, null, '\t'));
    //     } else if (error) {
    //         this.error = error;
    //     }
    // }


    connectedCallback(){
        console.log(this.recordId);
        this.loadData();
    }

    loadData(){
        getContact({conId: this.recordId})
        .then(result => {
            console.log(JSON.stringify(result));
            this.contact = result;
            console.log(this.contact.Name);
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })
    }

    openModel(){
        this.showModaFlag = true;
        this.conFirstName = this.contact.FirstName;
        this.conLastName = this.contact.LastName;
    }
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.showModaFlag=false;
    }

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

    openNewWindow() {  
        window.open('https://bhargavb2v-dev-ed.lightning.force.com/c/ContactEditApp.app?id='+this.recordId,"ContactEdit", "width=500,height=500");  
    }

    processMethod(){
        alert('Hi');
    }

    updateContact() {  
        this.conObj.FirstName = this.conFirstName;
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
        })
    }
}