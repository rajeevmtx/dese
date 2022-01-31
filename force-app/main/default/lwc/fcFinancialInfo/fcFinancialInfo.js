import {
    LightningElement,
    track,
    api
} from 'lwc';
export default class FcFinancialInfo extends LightningElement {
     @track helpTextVerification = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track dataObj = {};
    @track totalincome=0.00;
    @track grossincome=0;
    @track netincome=0;
    @track socialsecurity=0;
    @track pension=0;
    @track unemployment=0
    @track tanf=0;
    @track aptd=0;
    @track foodstamps=0;
    @track fuelassistance=0;
    @track otherincome=0;
    connectedCallback() {
        this.dataObj = {};
    }
    handleInput(event) {
        parseFloat(this.totalincome);
        if (event.target.name == 'grossincome') {
            this.dataObj.grossincome = event.target.value;
            this.grossincome=parseFloat(this.dataObj.grossincome);
        } else if (event.target.name == 'netincome') {
            this.dataObj.netincome = event.target.value;
            this.netincome=parseFloat( this.dataObj.netincome );
        } else if (event.target.name == 'socialsecurity') {
            this.dataObj.socialsecurity = event.target.value;
            this.socialsecurity=parseFloat( this.dataObj.socialsecurity);
        } else if (event.target.name == 'pension') {
            this.dataObj.pension = event.target.value;
            this.pension=parseFloat( this.dataObj.pension);
          
        } else if (event.target.name == 'unemployment') {
            this.dataObj.unemployment = event.target.value;
            this.unemployment=parseFloat( this.dataObj.unemployment);
          
        } else if (event.target.name == 'tanf') {
            this.dataObj.tanf = event.target.value;
            this.tanf=parseFloat( this.dataObj.tanf);
           
        } else if (event.target.name == 'aptd') {
            this.dataObj.aptd = event.target.value;
            this.aptd=parseFloat( this.dataObj.aptd);
         
        } else if (event.target.name == 'foodstamps') {
            this.dataObj.foodstamps = event.target.value;
            this.foodstamps=parseFloat( this.dataObj.foodstamps);
         
        } else if (event.target.name == 'fuelassistance') {
            this.dataObj.fuelassistance = event.target.value;
            this.fuelassistance=parseFloat( this.dataObj.fuelassistance);
         
        } else if (event.target.name == 'otherincome') {
            this.dataObj.otherincome = event.target.value;
            this.otherincome=parseFloat( this.dataObj.otherincome);
        
        } 
        this.totalincome=this.grossincome+ this.netincome+ this.socialsecurity+
                        this.pension+this.unemployment+this.tanf+ this.aptd+
                        this.foodstamps+this.fuelassistance+this.otherincome;
        console.log("income",this.totalincome);
            this.dataObj.totalincome = this.totalincome;

                       
        console.log('total' +JSON.stringify(this.dataObj));
    }
   
}