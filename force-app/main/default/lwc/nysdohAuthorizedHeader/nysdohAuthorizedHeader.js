import { LightningElement,api,track } from 'lwc';
import getUserDetails from '@salesforce/apex/UserInfoDetails.getUserDetails';
import Id from '@salesforce/user/Id';

export default class NysdohAuthorizedHeader extends LightningElement {
    userId = Id;
    @track user;
    constructor(){
        super();
        this.getUserName();
    }
    getUserName() {
        console.log('userId',userId);
        getUserDetails({recId: this.userId})
        .then(result => {
            //this.contacts = result;
            console.log('result>>',result);
        })
        .catch(error => {
            //this.error = error;
            console.log('error>',error);
        });
    }    
}