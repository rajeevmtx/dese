import { LightningElement  } from 'lwc';
import nysdohResource from '@salesforce/resourceUrl/NYSDOH_Resource';
import { NavigationMixin } from 'lightning/navigation';
export default class Nysdoh_landingcomponent extends NavigationMixin(LightningElement) {

    customImage = nysdohResource + '/images/baner1.png';  
    navigateToRegister(){
        console.log('In Functoin');
        location.href = '/NYSDOH/s/volunteer-registration';
        console.log('In Functoin To Navigation');
    }
}