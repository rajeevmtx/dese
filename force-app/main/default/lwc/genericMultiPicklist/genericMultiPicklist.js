import { LightningElement, api, track } from 'lwc';
//import getPicklistValues from '@salesforce/apex/covidTestController.getPicklistValues';

export default class GenericMultiPicklist extends LightningElement {

    @api educationOptionValue = [] ;
    @api width = 100;
    @api variant = '';
    @api label = '';
    @api name = '';
    @api dropdownLength = 5;
    @api optionValue = [];
    @track workLocationOption = [];

    // @api workLocationOption = [{ label: 'Location 1', value: 'Location 1', selected: false },
    // { label: 'Ektorp sofa', value: 'Ektorp sofa', selected: false },
    // { label: 'Poäng armchair', value: 'Poäng armchair', selected: false },
    // { label: 'Kallax shelving', value: 'Kallax shelving', selected: false },
    // { label: 'Billy bookcase', value: 'Billy bookcase', selected: false },
    // { label: 'Landskrona sofa', value: 'Landskrona sofa', selected: false },
    // { label: 'Krippan loveseat', value: 'Krippan loveseat', selected: false }];
    @track value_ = ''; //serialized value - ie 'CA;FL;IL' used when / if options have not been set yet
    @track isOpen = false;
    @api selectedPills = [];  //seperate from values, because for some reason pills use {label,name} while values uses {label:value}

    rendered = false;


    @api
    get options() {
        console.log('workLocationOption-->', this.workLocationOption);
        return this.workLocationOption
    }
    set options(options) {
        this.rendered = false;
        this.parseOptions(options);
        this.parseValue(this.value_);
    }

    @api
    get value() {
        let selectedValues = this.selectedValues();
        return selectedValues.length > 0 ? selectedValues.join(";") : "";
    }
    set value(value) {
        this.value_ = value;
        this.parseValue(value);

    }

    parseValue(value) {
        if (!value || !this.workLocationOption || this.workLocationOption.length < 1) {
            return;
        }
        var values = value.split(";");
        var valueSet = new Set(values);

        this.workLocationOption = this.workLocationOption.map(function (option) {
            if (valueSet.has(option.value)) {
                option.selected = true;
            }
            return option;
        });
        this.selectedPills = this.getPillArray();
    }

    parseOptions(options) {
        if (options != undefined && Array.isArray(options)) {
            this.workLocationOption = JSON.parse(JSON.stringify(options)).map((option, i) => {
                option.key = i;
                return option;
            });
        }
    }


    //private called by getter of 'value'
    selectedValues() {
        var values = [];
        //if no options set yet or invalid, just return value
        if (this.workLocationOption.length < 1) {
            return this.value_;
        }
        this.workLocationOption.forEach(function (option) {
            if (option.selected === true) {
                values.push(option.value);
            }
        });
        return values;
    }

    connectedCallback() {
        this.workLocationOption = this.educationOptionValue;
    }

    renderedCallback() {
    }



    get labelStyle() {
        return this.variant === 'label-hidden' ? ' slds-hide' : ' slds-form-element__label ';
    }

    get dropdownOuterStyle() {
        return 'slds-dropdown slds-dropdown_fluid slds-dropdown_length-5' + this.dropdownLength;
    }

    get mainDivClass() {
        var style = ' slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        return this.isOpen ? ' slds-is-open ' + style : style;
    }
    get hintText() {
        if (this.selectedPills.length === 0) {
            return "Select Work Location";
        }
        return "";
    }

    openDropdown() {
        this.isOpen = true;
    }
    closeDropdown() {
        this.isOpen = false;
    }

    /* following pair of functions are a clever way of handling a click outside,
       despite us not having access to the outside dom.
       see: https://salesforce.stackexchange.com/questions/255691/handle-click-outside-element-in-lwc
       I made a slight improvement - by calling stopImmediatePropagation, I avoid the setTimeout call
       that the original makes to break the event flow.
    */
    handleClick(event) {
        event.stopImmediatePropagation();
        this.openDropdown();
        window.addEventListener('click', this.handleClose);
    }
    handleClose = (event) => {
        event.stopPropagation();
        this.closeDropdown();
        window.removeEventListener('click', this.handleClose);
    }

    handlePillRemove(event) {
        event.preventDefault();
        event.stopPropagation();

        const name = event.detail.item.name;
        //const index = event.detail.index;

        this.workLocationOption.forEach(function (element) {
            if (element.value === name) {
                element.selected = false;
            }
        });
        this.selectedPills = this.getPillArray();
        this.despatchChangeEvent();

    }

    handleSelectedClick(event) {
        console.log('inselect');
        var value;
        var selected;
        event.preventDefault();
        event.stopPropagation();

        const listData = event.detail;

        value = listData.value;
        selected = listData.selected;

        console.log('List Data--', JSON.stringify(listData));
        //shift key ADDS to the list (unless clicking on a previously selected item)
        //also, shift key does not close the dropdown.
        if (listData.shift) {
            this.workLocationOption.forEach(function (option) {
                if (option.value === value) {
                    option.selected = selected === true ? false : true;
                }
            });
        }
        else {
            this.workLocationOption.forEach(function (option) {
                if (option.value === value) {
                    option.selected = selected === "true" ? false : true;
                }
                // } else {
                //     option.selected = false;
                // }
            });
            //this.closeDropdown();
        }

        this.selectedPills = this.getPillArray();
        this.despatchChangeEvent();

    }


    despatchChangeEvent() {
        let values = this.selectedValues();
        let valueString = values.length > 0 ? values.join(";") : "";
        const eventDetail = { value: valueString };
        const changeEvent = new CustomEvent('picklistchange', { detail: eventDetail });
        this.dispatchEvent(changeEvent);
    }


    getPillArray() {
        var pills = [];
        this.workLocationOption.forEach(function (element) {
            var interator = 0;
            if (element.selected) {
                pills.push({ label: element.label, name: element.value, key: interator++ });
            }
        });
        return pills;
    }


}