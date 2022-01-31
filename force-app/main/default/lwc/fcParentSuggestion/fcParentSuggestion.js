import { LightningElement, track } from 'lwc';
import profile_pic1 from '@salesforce/resourceUrl/NH_profile_pic5';
import profile_pic2 from '@salesforce/resourceUrl/NH_profile_pic6';
import profile_pic3 from '@salesforce/resourceUrl/NH_profile_pic7';

export default class FcParentSuggestion extends LightningElement {
    Portal_Add_New_Contact_Help_Text = 'In order place a child in a foster home, the foster parent must complete all of the following:';

    profileimage1 = profile_pic1;
    profileimage2 = profile_pic2;
    profileimage3 = profile_pic3;
    @track isOpenModal = false;
    @track isOpenPlacementModal = false;
    @track fosterParentDetails;
    @track results = [
        {
            'imageURL': this.profileimage1,
            'Name': 'Lauren Landry',
            'address': '88 North Main St Test City, NH 03015',
            'Marital_Status__c': 'Married',
            'Employment_Status__c': 'Full-time employee',
            'Homeowner_Status__c': 'Owner',
            'MatchPercentage': '90',
            'userDistance': '12',
            "reportAbuse": false,
            'homeInspection': true,
            'backgroundCheck': true,
            'financialStability': true,
            'licensed': true
        },
        {
            'imageURL': this.profileimage2,
            'Name': 'Bella Landry',
            'address': '88 North Main St Test City, NH 03015',
            'Marital_Status__c': 'Married',
            'Employment_Status__c': 'Full-time employee',
            'Homeowner_Status__c': 'Owner',
            'MatchPercentage': '90',
            'userDistance': '12',
            "reportAbuse": false,
            'homeInspection': true,
            'backgroundCheck': true,
            'financialStability': true,
            'licensed': true
        },
        {
            'imageURL': this.profileimage3,
            'Name': 'Mason Smith',
            'address': '221 Gabriel St, Hampton, NH 03015',
            'Marital_Status__c': 'Unmarried',
            'Employment_Status__c': 'Full-time employee',
            'Homeowner_Status__c': 'Owner',
            'MatchPercentage': '60',
            'userDistance': '40',
            "reportAbuse": true,
            'homeInspection': false,
            'backgroundCheck': true,
            'financialStability': true,
            'licensed': false
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