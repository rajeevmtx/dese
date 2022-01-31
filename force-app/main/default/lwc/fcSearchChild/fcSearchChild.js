import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FcSearchChild extends LightningElement {
    @track searchString = {};
    @track resultsFound = false;
    @track interestedInChild1;
    @track interestedInChild2;
    get yesnoOptions(){ return [{ label: 'Yes', value: 'Yes' },
                                { label: 'No', value: 'No' },]};
    get gender(){
        return [{   label:'Male',
                    value:''
                },
                {   label:'Female', 
                    value:''
                }
               ]
    } ;
    get AgeRange() {
        return [{
            label: "All",
            value: ""
        }, {
            label: "0 to 2 years",
            value: "0-2"
        },
        {
            label: "3 to 7 years",
            value: "3-7"
        },
        {
            label: "8 to 12 years",
            value: "8-12"
        },
        {
            label: "13 to 15 years",
            value: "13-15"
        },
        {
            label: "16 to 17 years",
            value: "16-17"
        },
        {
            label: "18 to 20 years",
            value: "18-20"
        }
        ];
    }
    // get resultsFound() {
    //     return this.results.length > 0;
    // }
    handleSearchChange(event) {
        try {
            if (event.target.value) {
                this.searchString[event.currentTarget.dataset.name] = event.currentTarget.value;
            } else {
                delete this.searchString[event.currentTarget.dataset.name];
            }
        } catch (error) {
            console.log('error occured: ', error);
        }
    }
    handleSearch() {
        this.results = [];
        console.log('searchString: ', JSON.stringify(this.searchString));
        try {
            // if (Object.keys(this.searchString).length === 0 && this.searchString.constructor === Object) {
            //     this.dispatchEvent(new ShowToastEvent({
            //         title: 'Error',
            //         message: 'Please enter the search criteria.',
            //         variant: 'error'
            //     }));
            // } else {                
                   this.resultsFound = true;        
            // }
        } catch (error) {
            console.log('error occured: ', error);
        }
    }
    handleClear() {
        this.resultsFound = false;
    }
    handleInterestInChild1() {
        this.interestedInChild1 = true;
    }
    handleInterestInChild2() {
        this.interestedInChild2 = true;
    }
}