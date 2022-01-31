import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAddressInformations from '@salesforce/apex/MtxIntakeFormController.getAddressInformation';
import intakeAddressMessage from '@salesforce/label/c.MTX_Intake_Address_Message';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class MtxAddressInformation extends LightningElement {
      @api subjectId;
      @track addressHelpText = "Please provide your personal details below with accurate information in case we need to contact you.";
      @track Address;
      @track showAddAddressModal = false;
      _AddressData;

      @track addressMessage = intakeAddressMessage;
      @track showEmptyMessage = false;
      @track addressInformationId;

      @wire(getAddressInformations, { 'subjectId' : '$subjectId' })
      getAddress(res) {
            this._AddressData = res;
            this.showEmptyMessage = false;
            if(res.error) {
                  console.error('error here', JSON.stringify(res.error));
            }                        
            else if(res.data){
                  console.log('data here', JSON.parse(JSON.stringify(res.data)));
                  this.Address = res;                                    
            }
            if(res.data == undefined || res.data.length == 0)
                  this.showEmptyMessage = true;

          console.log('this.showEmptyMessage---',this.showEmptyMessage);  
      }

      handleAddAddress() {
            this.addressInformationId = '';
            this.showAddAddressModal = true;
      }

      handleEditAddress(event) {
            var targetId = event.target.id;
            this.showAddAddressModal = true;
            var addressId = targetId.split('-');
            this.addressInformationId = addressId[0];
            console.log('this.addressInformationId---',this.addressInformationId);
            
      }

      goNext() {
            console.log('----Address'+this.Address.data.length);
            if(this.Address.data.length < 1){
                  const event = new ShowToastEvent({
                        title: 'Address',
                        message: 'You must add atleast one address before moving to next page.',
                        variant: 'error'
                    });
                    this.dispatchEvent(event);
            }
            else{
                  this.dispatchEvent(new CustomEvent('next'));
            }
      }

      goPrev() {
            this.dispatchEvent(new CustomEvent('prev'));
      }

      handleModalClose() {
            this.showAddAddressModal = false;
            return refreshApex(this._AddressData);
      }
}