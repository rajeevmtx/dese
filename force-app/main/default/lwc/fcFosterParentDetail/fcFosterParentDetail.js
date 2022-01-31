import { LightningElement, track } from 'lwc';
import profile_pic1 from '@salesforce/resourceUrl/NH_profile_pic1';
import profile_pic2 from '@salesforce/resourceUrl/NH_profile_pic2';
import nh_map from '@salesforce/resourceUrl/new_hampshire_map';
export default class FcFosterParentDetail extends LightningElement {
    profileimage1 = profile_pic1;
    profileimage2 = profile_pic2;
    map = nh_map;

    @track
    showFeatures = true;
    @track overview = true;
    @track joseph = false;
    @track brandy = false;
  saveMethod(event) {
    var x=event.target.id;
    console.log(x);
      // this.template.querySelector('.slds-show').classList.add('slds-hide');
      // this.template.querySelector('.slds-show').classList.remove('slds-show');
      // this.template.querySelector('.slds-is-active').classList.remove('slds-is-active');
       
      // var y=event.target.parentElement;
      // y.classList.add('slds-is-active');
            
      
      
     if(x.includes('tabs-0')){
       this.overview = true;
       this.joseph = false;
       this.brandy = false;
     }
     if(x.includes('tabs-1')){
      this.overview = false;
      this.joseph = true;
      this.brandy = false;
    }
    if(x.includes('tabs-2')){
      this.overview = false;
      this.joseph = false;
      this.brandy = true;
    }

      // let target = this.template.querySelector(`[aria-labelledby="${x}"]`);
    
      // target.classList.remove('slds-hide');
      // target.classList.add('slds-show');
  }
}