import { LightningElement } from 'lwc';
import nh_logo_white from '@salesforce/resourceUrl/NH_logo_white';
import { NavigationMixin } from "lightning/navigation";

export default class FcFosterCareHome extends NavigationMixin(LightningElement) {
  logo = nh_logo_white;

  navigateToPage(event) {
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: event.target.dataset.navigatepage
      }
    });
  }

  handleHover(event) {
    let tile = event.target.dataset.tile;

    // if (tile === 'attend') {
      let which = this.template.querySelector(`[data-tile="${tile}"]`);
      which.classList.add('change-hover');
      which.classList.remove('add-line-clamp');
      let main = this.template.querySelector(`[data-maintile="${tile}"]`);
      main.classList.add('main-tile');
    // }
  }

  mouseOut(event) {
    let allEls = this.template.querySelectorAll('[data-out="out"]');
    console.log('how many: ', allEls.length);
    allEls.forEach(element => {
      element.classList.remove('change-hover');
      element.classList.add('add-line-clamp');
    });

    let allMains = this.template.querySelectorAll('[data-main="out"]');
    console.log('how many: ', allEls.length);
    allMains.forEach(element => {
      element.classList.remove('main-tile');
    });

  }
}