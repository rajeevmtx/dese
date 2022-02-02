/**
 * Created by AshishP on 21-01-2020.
 */

import { LightningElement, api, track } from "lwc";
// importing to show toast notifictions
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContactData from "@salesforce/apex/PsrContactListController.getContact";
import getApplicationContactData from "@salesforce/apex/PsrContactListController.getApplicationContact";
import createApplicationContact from "@salesforce/apex/PsrContactListController.createContact";
import { utility } from "c/pubsub";
import Portal_Add_New_Contact_Help_Text from "@salesforce/label/c.Portal_Add_New_Contact_Help_Text";

export default class psrNewContact extends LightningElement {
    @api isOpenModal = false;
    @api contactId;
    @api applicationId;
    @api applicationContactId;
    @api isStaff = false;
    @api Portal_Add_New_Contact_Help_Text =
        "Please fill the below information: ";
    @track contact = {};
    accountId;

    get header() {
        return typeof this.applicationContactId == "undefined" ||
            this.applicationContactId == "" ||
            this.applicationContactId == null
            ? "Add New Student"
            : "Edit Student Details";
    }
    get headerStaff() {
        return typeof this.applicationContactId == "undefined" ||
            this.applicationContactId == "" ||
            this.applicationContactId == null
            ? "Add New Staff"
            : "Edit Staff Details";
    }

    roleOptions=[
        {
            label:'Teacher',
            value:'Teacher'
        },
        {
            label : 'Executive Director',
            value : 'Executive Director'
        },
        {
            label : 'Director',
            value : 'Director'
        },
        {
            label : 'Program Coordinator',
            value : 'Program Coordinator'
        },
        {
            label : 'Program Administrator',
            value : 'Program Administrator'
        },
        {
            label : 'Licensee',
            value : 'Licensee'
        }
    ];

    handleRoleChange(event){
        this.contact.Role = event.detail.value;
    }

    connectedCallback() {
        this.applicationId = utility.getUrlParam("appId");
        if (!this.checkBlank(this.applicationContactId)) {
            getApplicationContactData({
                applicationContactId: this.applicationContactId,
            })
                .then((result) => {
                    if (result) {
                        this.contact.accountId = result.accountId;
                        this.contact.firstName = result.firstName;
                        this.contact.lastName = result.lastName;
                        this.contact.email = result.email;
                        this.contact.phone = result.phone;
                        this.contact.companyName = result.companyName;
                        this.contact.type = result.type;
                        this.contact.enrollmentnumber = result.enrollmentnumber;
                        this.contact.status = result.status;
                        this.contact.title = result.title;
                        this.contact.comments = result.comments;
                        this.contact.elarNumber = result.elarNumber;
                        this.contact.hireDate = result.hireDate;
                        this.contact.Role = result.Role;
                        console.log(result.type);
                    }
                })
                .catch((err) => {
                    console.log("error here", JSON.stringify(err));
                });
        }
    }
    value = ["option1"];
    focusArea = [
        // {focus: 'Team Process', criterias: [ ]},

        // {focus: 'IEP,Placement,and Progress Reporting	', criterias: [ ]},

        {
            focus: "Assessments",
            criterias: [
                { label: "Initial Evaluation", value: "inev" },
                { label: "Re-evaluation", value: "reev" },
                {
                    label: "Extended/Independent Ed. Evaluation",
                    value: "exrev",
                },
            ],
        },

        {
            focus: "Transition	",
            criterias: [
                { label: "Early Intervention Program", value: "eaip" },
                { label: "Other Referral Source", value: "orc" },
                { label: "Student Aged 14-15", value: "sa14" },
                { label: "Student Aged 16-17", value: "sa16" },
                { label: "Student Aged 18+", value: "sa18" },
            ],
        },

        {
            focus: "Student Discipline	",
            criterias: [
                { label: "Interim Alternative Ed. Setting", value: "iaes" },
                { label: "Positive Behavioral Interventions", value: "pbi" },
                { label: "Suspended atleast 10 Days", value: "sa10d" },
            ],
        },

        // {focus: 'Out of District and Other Placements	', criterias: [ { label: 'Approved Program', value: 'ap' },
        // { label: 'Collaborative Out of District Program', value: 'codp' },
        // { label: 'ESIS', value: 'esis' },{ label: 'Private School at Private Expense', value: 'pspe' },
        // { label: 'Unapproved Program', value: 'ua' }]},
    ];
    get options() {
        return [
            { label: "Ross", value: "option1" },
            { label: "Rachel", value: "option2" },
        ];
    }

    get selectedValues() {
        return this.value.join(",");
    }

    handleChange(e) {
        this.value = e.detail.value;
    }
    handleOpenModal() {
        this.isOpenModal = true;
    }
    handleApplicationSuccess() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: "Success!!",
                message: "Contact Saved Successfully!!",
                variant: "success",
            })
        );
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("closemodal", {
            detail: "",
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.isOpenModal = false;
    }
    handleSubmit(event) {
        event.preventDefault();
        let fields = event.detail.fields;
        console.log(JSON.stringify(event.detail));
        //alert(fields.Company_Name__c);
        this.contact.contactId = this.contactId;
        this.contact.applicationId = this.applicationId;
        this.contact.id = this.applicationContactId;
        this.contact.firstName = fields.FirstName;
        this.contact.lastName = fields.LastName;
        this.contact.email = fields.Email;
        this.contact.phone = fields.Phone;
        // this.contact.companyName = fields.Company_Name__c;
        this.contact.type = fields.Contact_Type__c;
        // this.contact.enrollmentnumber = fields.Enrollment_Number__c;
        this.contact.hireDate = fields.Start_Date__c;
        this.contact.title = fields.Title;
        this.contact.elarNumber = fields.Prof_Qualification_Reg_Number__c;
        this.contact.status = fields.Status__c;
        //this.contact.Role = fields.Role__c;
        //alert(this.contact.Role);
        if (this.contact.comments != "12345") {
            alert("Fill Fields correctly");
            return;
        }
        //this.contact.comments = fields.Comments__c;
        let recordType = this.isStaff ? "Staff" : "Student";

        console.log("Contact Data: ", this.contact);
        createApplicationContact({
            jsonString: JSON.stringify(this.contact),
            recordTypeName: recordType,
        })
            .then((result) => {
                if (result) {
                    if (result == "success") {
                        this.handleApplicationSuccess();
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: "Error!!",
                                message: result,
                                variant: "error",
                            })
                        );
                    }
                }
            })
            .catch((err) => {
                console.log("error here", JSON.stringify(err));
            });
    }
    handleChangeNew(event) {
        if (event.target.name == "CompanyName")
            this.contact.companyName = event.target.value;
        else if (event.target.name == "EnrollmentNumber")
            this.contact.enrollmentnumber = event.target.value;
        else if (event.target.name == "Comments__c")
            this.contact.comments = event.target.value;
    }

    handleCloseModal() {
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("closemodal", {
            detail: "",
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        this.isOpenModal = false;
    }
    matchExisting(event) {
        this.retrieveContact(event.detail.value);
    }

    retrieveContact(email) {
        getContactData({ email: email })
            .then((result) => {
                if (result) {
                    this.contactId = result.Id;
                    this.contact.accountId = result.AccountId;
                    if (this.checkBlank(this.contact.firstName))
                        this.contact.firstName = result.FirstName;
                    if (this.checkBlank(this.contact.lastName))
                        this.contact.lastName = result.LastName;
                    if (this.checkBlank(this.contact.email))
                        this.contact.email = result.Email;
                    if (this.checkBlank(this.contact.phone))
                        this.contact.phone = result.Phone;
                    if (this.checkBlank(this.contact.companyName))
                        this.contact.companyName = result.Account.Name;
                }
            })
            .catch((err) => {
                console.log("error here", JSON.stringify(err));
            });
    }

    checkBlank(val) {
        if (val != "" && val != null && typeof val != "undefined") {
            return false;
        }
        return true;
    }
}