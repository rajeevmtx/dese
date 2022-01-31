import { LightningElement, track, api, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import font_awesome_css from '@salesforce/resourceUrl/font_awesome_css';
import headerseal from '@salesforce/resourceUrl/NysDohLogo';
import nyslogo from '@salesforce/resourceUrl/NYSStyles';
import psrCommunityBaseUrl from '@salesforce/label/c.Portal_URL';
import USER_ID from '@salesforce/user/Id';



import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import ER_Community_URL from '@salesforce/label/c.PR_Label';

export default class MtxIntakeHeader extends LightningElement {
    label = {
        ER_Community_URL,
    };


    @track error;
    @track userid;
    @track userEmail;
    @track userName;
    @track myProfileLink;
    @track showMenuItems = false;
    @track myProfile = false;
    @track logout = false;
    @track login = true;
    logo = headerseal;
    headerLogo = nyslogo + '/NYSLogo.png';
    
    connectedCallback() {
        if (USER_ID != undefined) {
            this.myProfile = true;
            this.logout = true;
            this.login = false;
        }

        //this.myProfileLink = 'https://dev-utahlg.cs22.force.com/er/s/profile/'+USER_ID;
        this.myProfileLink = psrCommunityBaseUrl + 'profile/' + USER_ID;
        console.log('99999999 ' + this.myProfileLink);
        Promise.all([
                loadStyle(this, font_awesome_css + '/font_awesome_css/fontawesome.css'),
                loadStyle(this, font_awesome_css + '/font_awesome_css/fontawesome.min.css'),
            ])
            .then(() => {
                // alert('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }

    showMenu(event) {
        let target = event.target;
        target.classList.toggle("change");
        if (this.showMenuItems) {
            this.template.querySelector('[data-id="menu-items"]').style.display = 'none';
        } else {
            this.template.querySelector('[data-id="menu-items"]').style.display = 'block';
        }
        this.showMenuItems = !this.showMenuItems;
    }
    gotoHomePage() {
        window.open(`/psr`, "_self");
    }
    goToMyProfile() {
        window.parent.location.href = this.myProfileLink;
    }
    openNotification() {
        console.log('In Notify');

        this.template.querySelector('.notification').classList.toggle('slds-hidden');
    }
}