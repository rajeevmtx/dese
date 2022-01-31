import { LightningElement, track } from 'lwc';
import profile_pic3 from '@salesforce/resourceUrl/NH_profile_pic3';
import profile_pic4 from '@salesforce/resourceUrl/NH_profile_pic4';
export default class FcInterstedParent extends LightningElement {
    profileimage1 = profile_pic3;
    profileimage2 = profile_pic4;

    Portal_Add_New_Contact_Help_Text = 'In order place a child in a foster home, the foster parent must complete all of the following:';

    @track isOpenModal = false;
    @track isOpenPlacementModal = false;
    @track fosterParentDetails;
    @track results = [
        {
            'imageURL': this.profileimage1,
            'Name': 'Julie Ward',
            'address': '88 North Main St Test City, NH 03015',
            'Marital_Status__c': 'Married',
            'Employment_Status__c': 'Full-time employee',
            'Homeowner_Status__c': 'Owner',
            'MatchPercentage': '91',
            'userDistance': '15',
            "reportAbuse": false,
            'homeInspection': true,
            'backgroundCheck': true,
            'financialStability': true,
            'licensed': true
        },
        {
            'imageURL': this.profileimage2,
            'Name': 'Alexis Bailey',
            'address': 'A23 Baker\'s Street Boston',
            'Marital_Status__c': 'Married',
            'Employment_Status__c': 'Full-time employee',
            'Homeowner_Status__c': 'Owner',
            'MatchPercentage': '92',
            'userDistance': '10',
            "reportAbuse": false,
            'homeInspection': true,
            'backgroundCheck': true,
            'financialStability': true,
            'licensed': true
        }
    ];


    showDetails(event) {
        console.log('this.fosterParentDetails 1' + this.fosterParentDetails);
        let delIndex = event.currentTarget.dataset.recordId;
        console.log('delIndex ' + delIndex);
        this.fosterParentDetails = this.results[delIndex];
        console.log('this.fosterParentDetails 2' + this.fosterParentDetails);
        this.isOpenModal = true;
    }

    handleCloseModal() {
        this.isOpenModal = false;
        this.isOpenPlacementModal = false;

    }
    showPlacements(event) {
        try {
            // console.log('this.fosterParentDetails 1' + this.fosterParentDetails);
            let delIndex = event.currentTarget.dataset.placement;
            console.log('delIndex ' + delIndex);
            // this.fosterParentDetails = this.results[delIndex];
            // // console.log('this.fosterParentDetails 2' + this.fosterParentDetails);
            // this.isOpenPlacementModal = true;
            let ele = this.template.querySelector(`[data-placement="${delIndex}"]`);
            ele.classList.add('placement-button');
        } catch (error) {
            console.log('error: ', error);
        }

    }


}