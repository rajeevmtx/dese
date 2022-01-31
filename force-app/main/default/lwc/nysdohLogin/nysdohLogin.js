import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import nysdohResource from '@salesforce/resourceUrl/NYSDOH_Resource';
import login from '@salesforce/apex/psrLoginController.login';
export default class Nysdoh_landingcomponent extends NavigationMixin(LightningElement) {

    @track showError = false;
    @track errorMessage = '';
    @track username ='';
    @track password = '';
    @track startUrl = 'https://dev-demo-lp.cs92.force.com/NYSDOH/s/volunteer-registration';
        
    customImage = nysdohResource + '/images/baner1.png';  
    navigateToRegister(){
        console.log('In Functoin');
        location.href = '/NYSDOH/s/volunteer-registration';
        console.log('In Functoin To Navigation');
    }

    nameChange(event) {    
        this.username= event.target.value;
    }
    passwordChange(event) {
        this.password= event.target.value;
    }
    
    doLogin() {
        console.log(this.username);
        console.log(this.password);
        login({username : this.username,  password : this.password,  startUrl : this.startUrl })
            .then(data => {
                console.log('Data-->' + data);
                this.navigateToRegister();
			})
            .catch(error => {
                this.showError = true;
                console.log('Error-->' + JSON.stringify(error.body.message));
                var msg = JSON.stringify(error.body.message);
                this.errorMessage = msg.substring(1, msg.length - 1);
			});
    }
 
}