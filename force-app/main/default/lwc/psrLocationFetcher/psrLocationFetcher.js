import { LightningElement,track,api } from 'lwc';
import getSuggestions from '@salesforce/apex/PsrLocationController.getSuggestions';
import getPlaceDetails from '@salesforce/apex/PsrLocationController.getPlaceDetails';
import permitSearchLocationState from '@salesforce/label/c.Permit_Search_Location_State';


export default class PsrLocationFetcher extends LightningElement {

    @track locations = '';
    @track location = '';

    @track predictions = [];
    @track isPrediction = false;
    label = {
        permitSearchLocationState,
    };

    get checkPrediction() {
        return this.predictions.length == 0?false:true;
    }


    getCities(event){	
        console.log('permitSearchLocationState---'+permitSearchLocationState)
        
        getSuggestions({input : event.target.value,stateLabel : permitSearchLocationState}).then(result => {
            var resp = JSON.parse(result);
            this.predictions = resp.predictions;

            if(this.predictions.length > 0){
                this.isPrediction = true;
            }
        })
        .catch(error => {
            this.error = error;
            console.log('error-->'+JSON.stringify(error));
        });
    }

    getCityDetails(event){		 
 
        let selectedItem = event.currentTarget;
        let placeid = selectedItem.dataset.placeid;
     
        getPlaceDetails({placeId : placeid}).then(result => {
            let placeDetails = JSON.parse(result);
            this.locations = placeDetails.result.address_components;
            this.location =placeDetails.result.formatted_address; 
            this.predictions = [];
            this.sendLocation();
        })
        .catch(error => {
            this.error = error;
            console.log('error-->'+error);
        });
    }

    sendLocation(){
        const selectedEvent = new CustomEvent("fetchinglocation", {
        detail: this.locations
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    
}