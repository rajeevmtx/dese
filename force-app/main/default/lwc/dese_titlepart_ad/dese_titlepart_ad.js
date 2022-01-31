import { LightningElement, api, track } from "lwc";
import getProposalDetails from "@salesforce/apex/DESE_Title1Controller.getProposalDetails";
import saveProposalDetails from "@salesforce/apex/DESE_Title1Controller.saveProposalDetails";
import fetchFiles from "@salesforce/apex/FileUploadController.fetchFiles";
import deleteFile from "@salesforce/apex/FileUploadController.deleteFile";
var checkboxSet = new Set();
import deseDesign from '@salesforce/resourceUrl/DESE_Design';

const columns = [
    {
        label: "Title",
        fieldName: "Title",
        wrapText: true,
        cellAttributes: {
            iconName: { fieldName: "icon" },
            iconPosition: "left",
        },
    },
    {
        label: "Delete",
        type: "button",
        typeAttributes: {
            label: "Delete",
            name: "Delete",
            variant: "destructive",
            iconName: "standard:record_delete",
            iconPosition: "right",
        },
    },
];

export default class Dese_titlepart_ad extends LightningElement {


    notebook = deseDesign + '/theme/images/notebook.png';

    @api projectId;
    @track proposalDetails = [];
    @track agreementValues = [];
    @track specificActivities;
    @track grades;
    @track attainmentGoals;
    @track specifyOthers;
    @track facilityName;
    @track contactName;
    @track phone;
    @track email;
    @track formalAgreement;
    @track checkBoxvalue = [];
    @track dataActivityValues;
    @track selectedAgreementValues;
    @track showContact;
    @track columnsList = columns;
    @track items = [];
    @track files = [];
    @track isLoading = false;
    @api readOnly;

    @track agreementOptions = [
        {
            label: "Description of all services to be provided to neglected or delinquent youth",
            value: "Description of all services to be provided to neglected or delinquent youth",
        },
        {
            label: "How participating schools and facilities will coordinate work with neglected or delinquent youth, including coordination with social, health and other service providers",
            value: "How participating schools and facilities will coordinate work with neglected or delinquent youth, including coordination with social, health and other service providers",
        },
        {
            label: "How transitions will be coordinated between schools and facilities for children returning from correctional facilities",
            value: "How transitions will be coordinated between schools and facilities for children returning from correctional facilities",
        },
        {
            label: "How students with different characteristics and needs will be served, including making the facilities aware of existing individualized education programs",
            value: "How students with different characteristics and needs will be served, including making the facilities aware of existing individualized education programs",
        },
        {
            label: "Any partnerships with local business to provide training and other services for participating students",
            value: "Any partnerships with local business to provide training and other services for participating students",
        },
        {
            label: "How the program will involve parents in improvement efforts for participants",
            value: "How the program will involve parents in improvement efforts for participants",
        },
        {
            label: "How this program will be coordinated with other federal, state and local programs serving at-risk children and youth",
            value: "How this program will be coordinated with other federal, state and local programs serving at-risk children and youth",
        },
    ];

    @track checkBoxOptions = [
        { label: "ACCESS data", value: "ACCESS" },
        {
            label: "Attendance data (educators)",
            value: "Attendance data (educators)",
        },
        {
            label: "Attendance data (students)",
            value: "Attendance data (students)",
        },
        { label: "CHART reports", value: "CHART reports" },
        {
            label: "College application,enrollment and completion data",
            value: "College application,enrollment and completion data",
        },
        { label: "DART reports", value: "DART reports" },
        { label: "Discipline data", value: "Discipline data" },
        { label: "District assessments", value: "District assessments" },
        {
            label: "District -sponsored research",
            value: "District -sponsored research",
        },
        {
            label: "Educator evaluation data",
            value: "Educator evaluation data",
        },
        {
            label: "Early warning Indicator System (EWIS) data",
            value: "Early warning Indicator System (EWIS) data",
        },
        {
            label: "Learning walks/teacher observation",
            value: "Learning walks/teacher observation",
        },
        { label: "MCAS data", value: "MCAS data" },
        {
            label: "Peer-reviewed research",
            value: "Peer-reviewed research",
        },
        { label: "RADAR reports", value: "RADAR reports" },
        { label: "Student report cards", value: "Student report cards" },
        {
            label: "Student accountablity data",
            value: "Student accountablity data",
        },
        {
            label: "Student Learning Experience reports",
            value: "Student Learning Experience reports",
        },
        {
            label: "Survey - School Climate (student)",
            value: "Survey - School Climate (student)",
        },
        { label: "Survey - Other", value: "Survey - Other" },
        {
            label: "Workforce outcomes data",
            value: "Workforce outcomes data",
        },
        { label: "Other", value: "Other" },
        { label: "None", value: "None" },
    ];

    handledataChange(event) {
        console.log(event.target.value);
        switch (event.target.name) {
            case "specificActivities":
                this.specificActivities = event.target.value;
                break;
            case "grades":
                this.grades = event.target.value;
                break;
            case "attainmentGoals":
                this.attainmentGoals = event.target.value;
                break;
            case "specifyOthers":
                this.specifyOthers = event.target.value;
                break;
            case "facilityName":
                this.facilityName = event.target.value;
                break;
            case "contactName":
                this.contactName = event.target.value;
                break;
            case "phone":
                this.phone = event.target.value;
                break;
            case "email":
                this.email = event.target.value;
                break;
            case "formalAgreement":
                this.formalAgreement = event.target.value;
                break;
            case "DataPromptedActivity":
                this.DataPromptedActivity = event.target.value;
                this.items.push({ label: event.target.value });
                console.log("Items ", this.items);
                this.checkBoxvalue = event.target.value;
                this.dataActivityValues = this.checkBoxvalue.join(";");
                break;
            case "AgreementValues":
                this.agreementValues = event.target.value;
                this.selectedAgreementValues = this.agreementValues.join(";");
                break;
        }
    }

    handleItemRemove(event) {
        const index = event.detail.index;
        this.items.splice(index, 1);
    }

    handleButton(event) {
        if (event.target.name == "add") {
            this.showContact = true;
            this.showCancel = true;
        }

        if (event.target.name == "cancel") {
            this.showContact = false;
            this.showCancel = false;
        }
    }

    connectedCallback() {
        this.isLoading = true;
        getProposalDetails({ projectId: this.projectId })
            .then((data) => {
                console.log("Inside ConnectedCallback Title 1 AD", data);

                this.specificActivities = data.specificActivities;
                this.grades = data.grades;
                this.attainmentGoals = data.attainmentGoals;
                this.specifyOthers = data.specifyOthers;
                this.facilityName = data.facilityName;
                this.contactName = data.contactName;
                this.phone = data.phone;
                this.email = data.email;
                this.formalAgreement = data.formalAgreement;
                this.checkBoxvalue = data.dataActivityValues;
                this.dataActivityValues = data.dataActivityValues;
                this.agreementValues = data.agreementValues
                    ? data.agreementValues
                    : [];
                this.selectedAgreementValues = data.agreementValues
                    ? data.agreementValues
                    : [];

                if (
                    this.facilityName != "" &&
                    this.facilityName != "undefined" &&
                    this.facilityName != undefined
                ) {
                    console.log("facilityname ", data.facilityName);
                    this.showContact = true;
                    this.showCancel = false;
                }

                var pillsItem = this.dataActivityValues.split(";");
                for (let i = 0; i < pillsItem.length; i++) {
                    this.items.push({ label: pillsItem[i] });
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
        fetchFiles({
            projectId: this.projectId,
        })
            .then((result) => {
                console.log("fetchFiles result: ", JSON.stringify(result));
                this.files = JSON.parse(JSON.stringify(result));
                this.isLoading = false;
            })
            .catch((error) => {
                console.log("fetchFiles error: ", error);
                this.isLoading = false;
            });
        this.showContact = false;
    }

    @api submitRecord() {
        var itemValues = this.items.map(function (item) {
            return item["label"];
        });
        var ActivityValues = itemValues.join(";");
        console.log("Final Value", ActivityValues);

        var wrapperString = {
            specificActivities: this.specificActivities,
            grades: this.grades,
            attainmentGoals: this.attainmentGoals,
            specifyOthers: this.specifyOthers,
            facilityName: this.facilityName,
            contactName: this.contactName,
            phone: this.phone,
            email: this.email,
            formalAgreement: this.formalAgreement,
            dataActivityValues: ActivityValues,
            agreementValues: this.selectedAgreementValues,
        };

        saveProposalDetails({
            proposalId: this.projectId,
            wrapperString: JSON.stringify(wrapperString),
        })
            .then((data) => {
                if (data == "SUCCESS") {
                    console.log(JSON.stringify(data));
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }

    //Abel's Code:

    @track showAgreementUpload = false;
    @track showBudgetUpload = false;
    get showFiles() {
        if (this.files.length > 0) return true;
        return false;
    }
    get acceptedFormats() {
        return [".pdf", ".png", ".jpeg"];
    }

    handleCheckboxChange(event) {
        if (
            event.target.name == "formalAgreement" &&
            event.target.checked == true
        )
            this.showAgreementUpload = true;
        else if (event.target.name == "formalAgreement")
            this.showAgreementUpload = false;
        else if (event.target.name == "budget" && event.target.checked == true)
            this.showBudgetUpload = true;
        else if (event.target.name == "budget") this.showBudgetUpload = false;
    }
    handleUploaFinished(event) {
        this.isLoading = true;
        const uploadedFiles = event.detail.files;
        console.log("No. of files uploaded : " + uploadedFiles.length);
        fetchFiles({
            projectId: this.projectId,
        })
            .then((result) => {
                console.log("fetchFiles result: ", JSON.stringify(result));
                this.files = JSON.parse(JSON.stringify(result));
                this.isLoading = false;
            })
            .catch((error) => {
                console.log("fetchFiles error: ", JSON.stringify(error));
                this.isLoading = false;
            });
    }
    handlePreview(event) {
        let index = event.target.dataset.id;
        let baseURL = "https://" + location.host + "/";
        console.log(baseURL);
        let fileURL =
            baseURL +
            "sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=" +
            this.files[index].Id;
        console.log("FileURL: ", fileURL);
        window.open(fileURL, "_blank");
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case "Delete":
                this.handleDelete(row);
                break;
            default:
        }
    }
    handleDelete(row) {
        this.isLoading = true;
        deleteFile({
            contentDocumentId: row.ContentDocumentId,
        })
            .then((result) => {
                console.log("File Deleted successfully");
                this.files = [];
                fetchFiles({
                    projectId: this.projectId,
                })
                    .then((result) => {
                        console.log(
                            "fetchFiles result: ",
                            JSON.stringify(result)
                        );
                        this.files = JSON.parse(JSON.stringify(result));
                        this.isLoading = false;
                    })
                    .catch((error) => {
                        console.log(
                            "fetchFiles error: ",
                            JSON.stringify(error)
                        );
                        this.isLoading = false;
                    });
            })
            .catch((error) => {
                console.log("deleteFile Error: ", error);
            });
    }
}