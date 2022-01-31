import { LightningElement , api} from 'lwc';

export default class Aps_navBarInvestigationItem extends LightningElement {
    @api resultOptions=[];
    @api categoryOptions=[];

    handleItemSelection(event) {
        const liItems = this.template.querySelectorAll('.nav-bar__item');
        liItems.forEach(item => {
            if(item.classList.contains('slds-is-active')) {
                item.classList.remove('slds-is-active');
            }
        })
        console.log(event.target.classList); 
        const item = event.target;
        const liItem = item.closest('.nav-bar__item');
        liItem.classList.add('slds-is-active');
        console.log('item clicked'+event.currentTarget.dataset.type);
        let wrapper = {
            name : event.currentTarget.dataset.name,
            type : event.currentTarget.dataset.type
         };
        //detail : wrapper
        this.dispatchEvent(new CustomEvent('itemselection', {detail : wrapper , bubbles: true}));
    }
}