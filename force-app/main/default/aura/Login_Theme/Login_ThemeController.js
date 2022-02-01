({
    initialize: function(component) {
        var url = $A.get('$Resource.loginbgimage');
        //var url = $A.get('$Resource.loginBg');
        //var url = $A.get('$Resource.imageSmoothingEnabled') + 'images/loginBg';
        component.set('v.backgroundImageURL', url);
      
    },
 
});