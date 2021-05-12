import { LightningElement ,api,wire,track} from 'lwc';
import getContacts from '@salesforce/apex/lwcTableController.getContacts';

export default class lwcTable extends LightningElement {
    @track columns = [{
            label: 'Id',
            fieldName: 'Id',
            type: 'text',
            sortable: true
        },
        {
            label: 'Name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Email',
            fieldName: 'email',
            type: 'text',
            sortable: true
        },
        {
            label: 'Phone',
            fieldName: 'phone',
            type: 'text',
            sortable: true
        },
        {
            label: 'Created Date',
            fieldName: 'createdDate',
            type: 'text',
            sortable: true
        }

    ];
    @track error;
    @track data ;
    @track searchKey;  
    isSearchChangeExecuted = false;  
    @api currentpage;  

    handleKeyChange(event) {  
        if (this.searchKey !== event.target.value) {  
          this.isSearchChangeExecuted = false;  
          this.searchKey = event.target.value;  
            console.log(Object.keys(this.data[0]));
        }  
      }  

    @wire(getContacts)
    wiredOpps({
        error,
        data
    }) {
        if (data) {
            this.data = data;
            console.log(data);
            console.log(JSON.stringify(data, null, '\t'));
        } else if (error) {
            this.error = error;
        }
    }
}