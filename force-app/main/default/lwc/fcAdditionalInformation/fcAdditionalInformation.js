import { LightningElement, track, api } from 'lwc';
import fetchAdditionalInformation from '@salesforce/apex/FC_ChildIntakeFormController.fetchAdditionalInformation';
export default class FcAdditionalInformation extends LightningElement {
    @track dataList = [];
    @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';

    fetchAdditionalInformationList(){
        this.showSpinner = true;
        fetchAdditionalInformation()
        .then(result => {
            this.dataList = JSON.parse(JSON.stringify(result));
            this.dataList.forEach(element => {
                if(element.question === 'Speciality Needs') {
                    element.question = 'Special Needs';
                }
            });
            console.log('this.dataList>>>' + JSON.stringify(this.dataList));
            this.showSpinner=false;
        })
        .catch(error => {
            this.erroMsg = error.message || error.body.message;
            this.showSpinner=false; 
        });
    }
    
    handleInput(event) {
        let index = event.currentTarget.dataset.index;
        if (event.target.name === 'selected') {
            this.dataList[index].selected = event.target.checked;
        }
    }
    @api
    isValid(){
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        return valid;
    }

    @api
    getData(){ 
        return this.dataList;
    }
    connectedCallback(){
        this.fetchAdditionalInformationList();
    }
}