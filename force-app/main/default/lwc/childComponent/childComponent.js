import { api, LightningElement } from 'lwc';

export default class ChildComponent extends LightningElement {
    value;
    @api valueFromAura; 
    handleChange(event) {
        this.value = event.target.value;
    }
    handleSubmit() {
        console.log('LWC HANDLE VALUE -> ', this.value);
        // const value = this.value;
        this.dispatchEvent(
            new CustomEvent('submitevent', {
                detail: { value : this.value }
            })
        );
    }
}
