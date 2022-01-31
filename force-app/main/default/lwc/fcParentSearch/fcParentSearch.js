import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import profile_pic1 from '@salesforce/resourceUrl/NH_profile_pic1';
import profile_pic2 from '@salesforce/resourceUrl/NH_profile_pic2';

import getMatchingRecords from "@salesforce/apex/FC_Search.getMatchingRecords";

export default class FcParentSearch extends LightningElement {
    @track results;
    Portal_Add_New_Contact_Help_Text = 'In order place a child in a foster home, the foster parent must complete all of the following:';

    @track searchString = {};
    profileimage1 = profile_pic1;
    profileimage2 = profile_pic2;
    @track isOpenModal = false;
    @track isOpenPlacementModal = false;

    @track fosterParentDetails;

    get AcceptSiblingsGroup() {
        return [
            {
                label: "Yes", value: "Yes"
            },
            {
                label: "No", value: "No"
            }
        ]
    }

    get SchoolDistricts() {
        return [
            {
                label: "Yes", value: "Yes"
            },
            {
                label: "No", value: "No"
            }
        ]
    }

    get SpecialNeeds() {
        return [
            {
                label: "Yes", value: "Yes"
            },
            {
                label: "No", value: "No"
            }
        ]
    }

    get RadiusOptions() {
        return [{
            label: "1 mile",
            value: "1 mile"
        },
        {
            label: "5 mile",
            value: "5 mile"
        },
        {
            label: "10 mile",
            value: "10 mile"
        },
        {
            label: "15 mile",
            value: "15 mile"
        },
        {
            label: "20 mile",
            value: "20 mile"
        },
        {
            label: "25 mile",
            value: "25 mile"
        }
        ];
    }
    get careTypes() {
        return [{
            label: "General Care",
            value: ""
        }, {
            label: "Specialized Care",
            value: ""
        },
        {
            label: "Emergency Care",
            value: ""
        },
        {
            label: "Crisis Care",
            value: ""
        }];
    }
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
    get CoreType() {
        return [{
            label: "New",
            value: "New"
        },
        {
            label: "Old",
            value: "Old"
        }
        ];
    }
    get MaritalStatus() {
        return [{
            label: "Unmarried",
            value: "Unmarried"
        },
        {
            label: "Married",
            value: "Married"
        }
        ];
    }
    get EmploymentStatus() {
        return [{
            label: "Employed",
            value: "Employed"
        },
        {
            label: "Unemployed",
            value: "Unemployed"
        }
        ];
    }
    get homeOwnerStatus() {
        return [{
            label: "New",
            value: "New"
        },
        {
            label: "Old",
            value: "Old"
        }
        ];
    }

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

    get resultsFound() {
        return this.results.length > 0;
    }

    handleSearch() {
        this.results = [];
        console.log('searchString: ', JSON.stringify(this.searchString));
        try {
            /*  if (Object.keys(this.searchString).length === 0 && this.searchString.constructor === Object) {
                  this.dispatchEvent(new ShowToastEvent({
                      title: 'Error',
                      message: 'Please enter the search criteria.',
                      variant: 'error'
                  }));
              } else {  */
            this.results = [
                {
                    'imageURL': this.profileimage1,
                    'Name': 'Joseph Wayne',
                    'address': '27 Elgar City Pkwy Elgar NH 03158 US',
                    'Marital_Status__c': 'Married',
                    'Employment_Status__c': 'Employed',
                    'Homeowner_Status__c': 'Owner',
                    'userDistance': '12',
                    "reportAbuse": false,
                    'homeInspection': true,
                    'backgroundCheck': true,
                    'financialStability': true,
                    'licensed': true
                },
                {
                    'imageURL': this.profileimage2,
                    'Name': 'Brandy Wayne',
                    'address': '27 Elgar City Pkwy Elgar NH 03158 US',
                    'Marital_Status__c': 'Married',
                    'Employment_Status__c': 'Employed',
                    'Homeowner_Status__c': 'Owner',
                    'userDistance': '12',
                    "reportAbuse": false,
                    'homeInspection': true,
                    'backgroundCheck': true,
                    'financialStability': true,
                    'licensed': true
                }
            ];
            console.log(results);
            //     getMatchingRecords({ searchString: JSON.stringify(this.searchString) })
            //         .then(result => {
            //             if (result.length > 0) {
            //                 let results = [];
            //                 let data = JSON.parse(JSON.stringify(result));
            //                 let index = 0;
            //                 data.forEach(element => {
            //                     if (index % 2 == 0) {
            //                         element.imageURL = this.profileimage1;
            //                     } else {
            //                         element.imageURL = this.profileimage2;
            //                     }
            //                     let address = [element.BillingAddress.street, element.BillingAddress.city, element.BillingAddress.state + '-' + element.BillingAddress.postalCode, element.BillingAddress.country];
            //                     address = address.join(', ');
            //                     element.address = address
            //                     results.push(element);
            //                     index += 1;
            //                 });
            //                 this.results = results;
            //             } else {
            //                 this.results = [];
            //             }
            //             console.log('Search results: ', JSON.stringify(this.results));

            //         })
            //         .catch(error => {
            //             console.log('error while searching: ', (error));
            //         });
            //}
        } catch (error) {
            console.log('error occured: ', error);
        }
    }

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

    handleClear() {
        let allFields = this.template.querySelectorAll('[data-name]');
        try {
            console.log('length of all fields: ', allFields.length);
            allFields.forEach(element => {
                element.value = null;
            });
            this.results = null;
        } catch (error) {
            console.log('error occured: ', error);
        }
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