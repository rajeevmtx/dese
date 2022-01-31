import { LightningElement, track, api } from 'lwc';

export default class FcDocuments extends LightningElement {
    @api applicationId;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track uploadedFiles = [
        {
            DocumentName: 'Financial information',
            fileName: '',
            status: 'Draft',
        },
        {
            DocumentName: 'Medical Form',
            fileName: '',
            status: 'Draft',
        },
        {
            DocumentName: 'Inspections',
            fileName: '',
            status: 'Draft',
        }
    ];
    @track showSpinner;

    handleFileUpload(event) {
        console.log('file name here', event.target.files[0].name);
        this.showSpinner = true;
        const fileName = event.target.files[0].name.split('.');
        switch(event.target.name) {
            case 'Financial information': {
                this.uploadedFiles[0].fileName = fileName[0];
                this.uploadedFiles[0].status = 'Submitted';
                break;
            }
            case 'Medical Form': {
                this.uploadedFiles[1].fileName = fileName[0];
                this.uploadedFiles[1].status = 'Submitted';
                break;
            }
            case 'Inspections': {
                this.uploadedFiles[2].fileName = fileName[0];
                this.uploadedFiles[2].status = 'Submitted';
                break;
            }
        }

        setTimeout(() => {
            this.showSpinner = false;
        }, 300);
    }
}