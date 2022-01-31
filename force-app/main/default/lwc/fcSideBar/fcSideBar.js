import {
    LightningElement, api, track, wire
} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import footerText from '@salesforce/label/c.Portal_Footer_Text';
import { getRecord } from 'lightning/uiRecordApi';

import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ER_Community_URL from '@salesforce/label/c.PR_Label';
import USER_ID from '@salesforce/user/Id';


export default class FcSideBar extends NavigationMixin(LightningElement) {
    @api showFooter;
    @api footerText = "Copyright © 2020 New Hampshire - All rights reserved.";

    @track showHelp = false;
    @track contactHelpTextShow = false;

    @track userName;

    yesnoOptions = [{ label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' },]



    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Name && data.fields.Name.value) {
                this.userName = data.fields.Name.value;
            }
        }
    }

    navigateToPage(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: event.target.dataset.navigatepage
            }
        });
    }

    get getHelpLabel() {
        return `Hi ${this.userName}, do you need any help?`;
    }


    handleHelp() {
        console.log('showHelp: ', this.showHelp);
        this.showHelp = !this.showHelp;
        this.contactHelpTextShow = false;
        this.queryList = [{
            text: `<strong class='intro'>Hello, I’m your virtual assistant. I'm here to help with your general enquiries.</strong> <br>Example of questions you can ask for demo purpose: <br><em>How can I submit an application?`,
            class: 'is-ai animation',
            aiText: true
        }];
    }

    handleOptionSelect(event) {
        if (event.target.value === 'Yes') {
            this.contactHelpTextShow = true;
        } else {
            this.contactHelpTextShow = false;
        }
    }

    @track queryList = [{
        text: `<strong class='intro'>Hello, I’m your virtual assistant. I'm here to help with your general enquiries.</strong> <br>Example of questions you can ask for demo purpose: <br><em>How can I submit an application?`,
        class: 'is-ai animation',
        aiText: true
    }];

    handleQuery(event) {
        try {
            console.log('event: ', event.target.dataset.button);
            var code = (event.keyCode ? event.keyCode : event.which);
            let isEscape = (event.key === "Escape" || event.key === "Esc");
            if (isEscape) {
                this.handleHelp();
            }
            else if (code == 13 || event.target.dataset.button === 'button') { //Enter keycode
                this.queryList.push({ text: this.template.querySelector('[data-query="query"]').value, class: 'is-user animation', aiText: false });
                console.log('check query2: ', this.template.querySelector('[data-query="query"]').value);
                let query = (this.template.querySelector('[data-query="query"]').value).toLowerCase();
                if (query.includes('application') || query.includes('submit') || query.includes('submission')) {
                    this.queryList.push({ text: 'Thanks for enquirying about application submission.', class: 'is-ai animation', aiText: true });
                } else if (query.includes('hi') || query.includes('hello') || query.includes('hey')) {
                    this.queryList.push({ text: 'Hi', class: 'is-ai animation', aiText: true });
                } else if (query.includes('how are ') || query.includes('how r')) {
                    this.queryList.push({ text: `I'm fine, How are you?`, class: 'is-ai animation', aiText: true });
                } else if (query.includes('good') || query.includes('great') || query.includes('fine') || query.includes('fantastic')) {
                    this.queryList.push({ text: `Nice to hear that!`, class: 'is-ai animation', aiText: true });
                } else if (query.includes('bye')) {
                    this.queryList.push({ text: `Have a nice day! Bye`, class: 'is-ai animation', aiText: true });
                    setTimeout(() => {
                        this.handleHelp();
                    }, 2000);
                } else {
                    this.queryList.push({ text: `Sorry, I didn't get that.`, class: 'is-ai animation', aiText: true });
                }
                this.template.querySelector('[data-query="query"]').value = null;

                setTimeout(() => {
                    var element = this.template.querySelector('[data-chat="chat"]');
                    element.scrollTop = element.scrollHeight;
                }, 100);

            }
        } catch (error) {
            console.log('error: ', error);
        }

    }
}