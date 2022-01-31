import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';


export default class Dese_readonly extends LightningElement {

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          console.log(currentPageReference.state.projectId,this.docusignEvent = currentPageReference.state.event)
          this.projectId = currentPageReference.state.projectId
       }
    }
}