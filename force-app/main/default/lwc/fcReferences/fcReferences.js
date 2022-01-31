import { LightningElement, track, api } from 'lwc';

export default class FcReferences extends LightningElement {
    @api applicationId;
    @track isOpenModal = false;
    @track helpText = 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.';
    @track contacts = [
        // {
        //     firstName: 'Pranay',
        //     lastName: 'Gupta',
        //     email: 'asd@asd.com',
        //     phone: '125125125'
        // }
    ];

    handleCloseModal() {
        this.isOpenModal = false;
    }

    onAddContact() {
        this.isOpenModal = true;
    }

    removeReference(event) {
        console.log('index here', event.target.dataset.index);
        const indexToRemove = event.target.dataset.index;
        this.contacts.splice(indexToRemove, 1);
    }

    handleAddContact() {
        console.log('inside add');
        const contactToAdd = {};
        this.template.querySelectorAll('lightning-input').forEach(input => {
            switch(input.name) {
                case 'firstName': {
                    contactToAdd.firstName = input.value;
                    break;
                }
                case 'lastName': {
                    contactToAdd.lastName = input.value;
                    break;
                }
                case 'email': {
                    contactToAdd.email = input.value;
                    break;
                }
                case 'phone': {
                    contactToAdd.phone = input.value;
                    break;
                }
            }
        });
        console.log('contact here', contactToAdd);
        this.contacts.push(contactToAdd);
        this.isOpenModal = false;
    }
}