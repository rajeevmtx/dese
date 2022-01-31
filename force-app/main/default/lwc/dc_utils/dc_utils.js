/**
 * @author Gaurav Shah
 * @email gaurav.shah@mtxb2b.com
 * @create date 2019-06-17 12:39:04
 * @modify date 2019-06-17 12:39:04
 * @desc [description]
 */
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


/**
 * Display a toast message
 * 
 * @param {*} component firing component
 * @param {*} params message display options
 */
export function showMessage(component, { title, message, messageType, mode }) {

    component.dispatchEvent(new ShowToastEvent({
        mode,
        title,
        message,
        variant: messageType,
    }));
}

/**
 * Display a success toast message
 * @param {LightningElement} component component displaying the message
 * @param {String} message message string
 */
export function showSuccessMessage(component, message) {
    showMessage(component, { title: "Success", message: message, messageType: 'success', mode: 'dismissable' });
}

/**
 * Display an info toast message
 * @param {LightningElement} component component displaying the message
 * @param {String} message message string
 */
export function showInfoMessage(component, message) {
    showMessage(component, { title: "Info", message: message, messageType: 'info', mode: 'dismissable' });
}

/**
 * Display a Warning toast message
 * @param {LightningElement} component component displaying the message
 * @param {String} message message string
 */
export function showWarningMessage(component, message) {
    showMessage(component, { title: "Warning", message: message, messageType: 'warning', mode: 'pester' });
}

/**
 * Display an error toast message
 * @param {LightningElement} component component displaying the message
 * @param {String} message message string
 */
export function showErrorMessage(component, message) {
    showMessage(component, { title: "Error", message: message, messageType: 'error', mode: 'pester' });
}

/**
 * Display an ajax type error message. takes in generic Exception object as input
 * @param {LightningElement} component component displaying the message
 * @param {Error} message message string
 */
export function showAjaxErrorMessage(component, error) {
    showMessage(component, {
        title: "Error",
        message: (error)?((error.message)?error.message:((error.body)?((error.body.message)?error.body.message:JSON.stringify(error)):JSON.stringify(error))):"Something went wrong!",
        messageType: 'error',
        mode: 'pester'
    });
}

export function getUniqueID() {
    // Math.random should be unique because of its seeding algorithm.
    // Convert it to base 36 (numbers + letters), and grab the first 9 characters
    // after the decimal.
    return '_' + Math.random().toString(36).substr(2, 9);
}