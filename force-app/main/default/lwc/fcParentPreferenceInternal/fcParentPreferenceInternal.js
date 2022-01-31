import { LightningElement, wire, track ,api} from 'lwc';
import getPrefrences from '@salesforce/apex/FC_ParentPreferenceController.getAccountPrefrences';
import setPreferenceWeightage from '@salesforce/apex/FC_ParentPreferenceController.setPreferenceWeightage';
import savePrefrences from '@salesforce/apex/FC_ParentPreferenceController.savePrefrences';
import fetchPicklist from '@salesforce/apex/FC_ParentPreferenceController.fetchPicklist';
import { loadStyle } from 'lightning/platformResourceLoader';
import myResource from '@salesforce/resourceUrl/fcPreferenceCss';

export default class FcParentPreferenceInternal extends LightningElement {

    @track dataList = [];
    @track selectedData = {};
    @track selectedObject = {};
    @track isShowModal = false;
    @track showSpinner = false;
    @track showPicklist = false;
    @track picklistValues = [];
    @track showList = true;
    @api recordId;


    renderedCallback() {
        Promise.all([
            loadStyle(this, myResource + '/main.css')
        ]).catch(error => {
            // eslint-disable-next-line no-console
            console.log(error);

        });
    }

    getPrefrencesList() {
        this.showSpinner = true;
        getPrefrences({ accountId : this.recordId})
            .then(result => {
                this.dataList = result;
                console.log('this.dataList>>>' + JSON.stringify(this.dataList));
                this.showSpinner = false;
            })
            .catch(error => {
                this.erroMsg = error.message || error.body.message;
                this.showSpinner = false;
            });
    }

    openModal(event) {
        var type = event.currentTarget.dataset.type;
        console.log('type>>>', type);
        fetchPicklist({ type: type })
            .then(result => {
                console.log('type>>>', result);
                this.picklistValues = result;
                if (result.length != 0) {
                    this.showPicklist = true;
                } else {
                    this.showPicklist = false;
                }
            })
            .catch(error => {
                let message = error.message || error.body.message;
                console.log('Error: ' + message);
            });

        this.selectedData = {};
        this.selectedObject.preferenceId = event.target.name;
        console.log('preferenceId-- ' + event.target.name);
        if (event.target.name) {
            for (let i = 0; i < this.dataList.length; i++) {
                if (event.target.name == this.dataList[i].preferenceId) {
                    this.selectedData = this.dataList[i];
                    break;
                }
            }
        }
        this.fillCurrentData();
        this.isShowModal = true;
    }
    handleInput(event) {
        if (event.target.name === 'value') {
            this.selectedObject.value = event.target.value;
        }
        else if (event.target.name === 'startDate') {
            this.selectedObject.startDate = event.target.value;
        }
        else if (event.target.name === 'endDate') {
            this.selectedObject.endDate = event.target.value;
        }
    }
    handleModalClose() {
        this.isShowModal = false;
    }
    handleSaveRecord() {
        if (this.isValid()) {
            this.showSpinner = true;
            savePrefrences({ jsonData: JSON.stringify(this.selectedObject) })
                .then(result => {
                    this.selectedData = result;
                    this.isShowModal = false;
                    this.getPrefrencesList();
                    this.showSpinner = false;
                })
                .catch(error => {
                    this.erroMsg = error.message || error.body.message;
                    this.showSpinner = false;
                });
        }
    }
    fillCurrentData() {
        this.selectedObject.id = this.selectedData.preferenceId;
        this.selectedObject.type = this.selectedData.type;
        this.selectedObject.value = this.selectedData.value;
        this.selectedObject.startDate = this.selectedData.startDate;
        this.selectedObject.endDate = this.selectedData.endDate;
        this.selectedObject.durationRequired = this.selectedData.durationRequired;
    }
    isValid() {
        let valid = false;
        let isAllValid = [...this.template.querySelectorAll('lightning-input')].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        valid = isAllValid;
        console.log('Valid Personal Information : ' + valid);
        return valid;
    }
    connectedCallback() {
        this.getPrefrencesList();
    }
    handleSliderChange(event) {
        
        var perferenceId = event.target.name;

        console.log('weightage-->', event.target.value);
        console.log('perferenceId-->', perferenceId);
        
        setPreferenceWeightage({ perferenceId : perferenceId,weightage: event.target.value })
        .then(result => {
            console.log('Success');
        })
        .catch(error => {
            let message = error.message || error.body.message;
            console.log('Error: ' + message);
        });
    }
    changeView(event) {
        if(event.target.name == 'listType') {
            this.showList = true;
        } else if (event.target.name == 'gridType') {
            this.showList = false;
        }
    }
}