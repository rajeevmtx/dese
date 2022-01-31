import { LightningElement, track, api } from 'lwc';
//import showThankYouHelpText from '@salesforce/label/c.NM_CT_Confirmation_Help_Text';

export default class FcChildIntakeThankYou extends LightningElement {
    @api volunteerNumber;
    //@track showThankYouHelpText = showThankYouHelpText
    // @track showThankYouHelpText = 'Thank you for submitting your application. Your application has been received';

    @track showThankYouHelpText = `<p>Thank you for your report. Your report will be forwarded to the District Office for assessment, a Case Worker will meet with the
    family/person and interview any household members. The discussions will focus on eliminating danger, identifying strengths and the resources of the family, and how to partner with the family to meet the needs of the person of concern. When an assessment is completed it may result in:</p>
    <p>1) A decision is made to close the assessment without action</p>
    <p>2) Close the assessment with referrals to community services</p>
    <p>3) Open a non-court case</p>
    <p>4) File a petition of abuse or neglect in the Court</p>
    
    <p>If abuse and/or neglect did occur DCYF and BEAS
    shall take action deemed necessary to assure the safety of the children, youth, or adult. The Case Worker
    will collaborate with families to develop a plan and find appropriate community programs to connect them
    with to address their needs. Community based services will be utilized to help families make positive change
    and help prevent abuse and neglect.</p>`;
    @track website = '';
    @track claimNumberMsg = '';
    @api caseRec = {};

    handleDone() {
        location.reload();
    }
    // renderedCallback() {
    //     let now = this.template.querySelector('[data-alert="alert]');
    //     now.style.removeProperty('max-width');
    // }
}