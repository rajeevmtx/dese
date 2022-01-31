import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import getConversations from '@salesforce/apex/DC_ConversationsController.getConversations';

export default class MtxConversations extends LightningElement {
    @api recordId;
    @track conversations;
    @track isEditName = false;
    @track message = '';
    @track lastRefreshDate;

    connectedCallback() {
        if(this.recordId){
            this.handleLoad();
            this.getLastRefreshConversation();
        }
    }
    handleLoad() {
        getConversations({
                recId: this.recordId
            })
            .then(result => {
                for (let i in result) { 
                    result[i].MessageType = ( result[i].Type__c == 'Inbound' ? 'c-outbound_message':'c-inbound_message');
                    result[i].isInbound = ( result[i].Type__c == 'Inbound' );
                }
                this.conversations = result;

                console.table(result);
            })
            .catch(error => {
                this.error = error;
            });
    }

    editName() {
        this.isEditName = true;
    }
    removeEditName(event) {
        this.message = event.target.value;
        this.isEditName = false;
    }
    
    // from this function we are getting the last refresh time.
    getLastRefreshConversation(){
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        var time = today.getHours() + ":" + today.getMinutes() + ":" + today.getSeconds();
        var dateTime = date+' '+time;
        this.lastRefreshDate = dateTime;
    }
    
    // from this function we are refreshing the conversation.
    refresh(){
        if(this.recordId){
            this.handleLoad();
            this.getLastRefreshConversation();
        }       
    }

}