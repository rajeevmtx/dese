({
	getBaseURL:function(component, event, helper)  {
   
    var url = location.href;  // entire url including querystring - also: window.location.href;
        console.log('URL--'+ url)
    var baseURL = url.substring(0, url.indexOf('/', 14));
		console.log('baseURL--'+ baseURL)
 		return baseURL + "/lightning/";
   }
		
	
})