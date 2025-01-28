({
    handleSubmit : function(component, event) {
        console.log("hello!!! -> ", event);
        console.log("hello!!! -> ", event.getParams());
        
        console.log("hello!!!! in AURA Component -> ", event.detail);
        console.log("hello!!!! in AURA Component -> ", event.getParam("value"));
        let value = event.getParam("value");
        console.log('VALUE AURA -> ', value);
        component.set('v.valueFromLWC', value);
        component.set('v.valueFromAura', value + " This is added in AURA");
        // this.value = event.target;
    },

})
