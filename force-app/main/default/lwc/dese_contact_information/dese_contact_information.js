import { api, LightningElement, track } from 'lwc';
import saveContact from '@salesforce/apex/DESE_IntakeContactController.saveContact'
import fetchContacts from '@salesforce/apex/DESE_IntakeContactController.fetchContacts'

export default class Dese_contact_information extends LightningElement {

    //radio button
    value = '';
    activeSection = 'Title I';
    mapData = {};
    @api projectId;
    @api readOnly;
    showSpinner = false;
    @track contacts = [
        { section: 'Title I', sectionLabel: 'Title I, Part A, Improving Basic Programs & Part D, Programs for Neglected, Delinquent and At-Risk Students',role: 'Title I' },
        { section: 'Title II', sectionLabel: 'Title II, Part A, Supporting Effective Instruction',role: 'Title II' },
        { section: 'Title III', sectionLabel: 'Title III, Part A, Support for English Learners and Immigrant  Students' ,role: 'Title III'},
        { section: 'Title IV', sectionLabel: 'Title IV, Part A, Student Support and Academic Enrichment' ,role: 'Title IV'},
        { section: 'EdGrants', sectionLabel: 'EdGrants Control User (person responsible for uploading to EdGrants, if different person from above roles)',role: 'EdGrants',isContact:true }
    ]

    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }
    //
    activeSectionMessage = '';


    connectedCallback() {
        console.log(this.projectId);
        fetchContacts({ projectId: this.projectId }).
            then( result => {
                this.contacts.forEach(contact => {
                    for(let key in result){
                        if(contact.section == key){
                            contact = Object.assign(contact,result[key])
                        }
                    }
                })
                console.log(JSON.parse(JSON.stringify(this.contacts)));
            }).
            catch( error => {
                console.log(error);
            })
    }
    genericHandler(event) {
        var inputname = event.currentTarget.dataset.id;
        var index = event.currentTarget.dataset.index;
        this.contacts[index][inputname] = event.target.value;
        this.contacts[index].isChanged = true;
    }

    handleToggleSection(event) {
        this.activeSection = event.detail.openSections;
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    handleNext() {
        /*debugger;
        const accordion = this.template.querySelector('.example-accordion');
        if (this.activeSection == 'Title I') {
            this.activeSection = 'Title II';
            accordion.activeSectionName = 'Title II';
            return;
        }
        if (this.activeSection == 'Title II') {
            this.activeSection = 'Title III';
            accordion.activeSectionName = 'Title III';
            return;
        }
        if (this.activeSection == 'Title III') {
            this.activeSection = 'Title IV';
            accordion.activeSectionName = 'Title IV';
            return;
        }
        if (this.activeSection == 'Title IV') {
            this.activeSection = 'EdGrants';
            accordion.activeSectionName = 'EdGrants';
            return;
        }*/
        console.log(JSON.parse(JSON.stringify(this.contacts)));
        this.showSpinner = true;
        saveContact({ contacts: this.contacts, projectId: this.projectId })
            .then(result => {
                console.log(result);
                this.dispatchEvent(new CustomEvent('next'));
            })
            .catch(error => {
                console.log(error);
            }).finally(()=>{
                this.showSpinner = false;
            })


    }

    handlePrev() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
}