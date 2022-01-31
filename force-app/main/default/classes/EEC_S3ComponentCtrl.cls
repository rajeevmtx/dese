/**
 * EEC_S3ComponentCtrl
 * 
 * This component is used to store all AWS S3 related functions for Salesforce.
 * @author Darkis
 */
global class EEC_S3ComponentCtrl {
    
  /**
     * generatePolicySignature
     * 
     * This function will generate a policy and signature for the to be uploaded file.
     * @author Darkis
     * @param String bucket The bucket name.
     * @param String acl The access param requested on the item.
     * @param String type The type of the file. i.e. image/png
     */
    global static Map<String, String> generatePolicySignature(String bucket, String acl, String filename, String type, String redirectUrl) {
      Map<String, String> policySigMap = new Map<String, String>();
      try {
        // Default variables.
        Blob s3Json = null;
        String macUrl;
        // Get an expiry for the upload signature.
        datetime expire = system.now().addDays(1);
        String formattedexpire = expire.formatGmt('yyyy-MM-dd')+'T'+expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';            
        // Create the policy.  
        if (!String.isBlank(redirectUrl)) {
          s3Json = Blob.valueOf(
            '{ "expiration": "'+formattedexpire+'","conditions": [' + 
            '{"bucket": "' + bucket + '" },' +
            '{ "acl": "' + acl + '" },'+
            '{"content-type":"' + type + '"},'+
            '{"success_action_redirect": "'+redirectUrl+'"},' + 
            '{"x-amz-server-side-encryption": "AES256"},' +
            '{"filename": "'+ filename +'"},' +
            '["starts-with", "$key", ""] ]}'
          );    
        } else {
          s3Json = Blob.valueOf(
            '{ "expiration": "'+formattedexpire+'","conditions": [' + 
            '{"bucket": "' + bucket + '" },' +
            '{ "acl": "' + acl + '" },'+
            '{"content-type":"' + type + '"},'+
            '{"x-amz-server-side-encryption": "AES256"},' +
            '{"filename": "'+ filename +'"},' +
            '["starts-with", "$key", ""] ]}'
          );                
        }
        String policy = EncodingUtil.base64Encode(s3Json);  
        // Get credentials  
        AWSKeys credentials = new AWSKeys('EEC'); 
        // Create the signing key.
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(credentials.secret_encrypted));
        // Create the sig using the policy and secret.
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(policy),blob.valueof(credentials.secret_encrypted)); 
        // Base 64 encode the sig.
        macUrl = EncodingUtil.base64Encode(mac); 
        // Add the two items to the list.
        policySigMap.put('policy', policy);
        policySigMap.put('signature', macUrl);
          
        if (!String.isBlank(redirectUrl)) {
          policySigMap.put('redirect', EncodingUtil.urlEncode(redirectUrl, 'UTF-8'));
        } 
      } catch (Exception e) {
        System.debug('Error: ' + e.getMessage());
        policySigMap.put('error', 'An error has occured. Please contact your administrator.');
      }
      return policySigMap;
    }
    
  /**
   * verifyUpload
   * 
   * This function can be used as a way to verify that a file has been uploaded to S3. It does
   *   a GET request for the file and will check for the document body. If the body exceeds the 
   *   callout limit we can safely assume it's available. If there is xml returned from AWS with
   *   an error tag then assume the file is not present. NOTE: If the file was specified as
   *   private then an error should occur and this function will assume the file doesn't exist.
   * @author Darkis
   * @param String filename The name of the file.
   * @param String bucket The name of the specified bucket.
   */
  /*global static Boolean verifyUpload(String filename, String bucket) {
    // Generate the URL.
    String url = 'https://s3.amazonaws.com/' + bucket + '/' + filename;
    // Make a new request for the item.  
    HttpRequest request = new HttpRequest();
    request.setMethod('GET');
    request.setEndpoint(url);
    // Initalize the reponse.
    HttpResponse res = null;
      
    try {
      // Submit the request.  
      res = new Http().send(request);
      // Check for the image result.
      // Get the return as xml.
      XmlStreamReader result = res.getXmlStreamReader();
      // Check the result for <Error> tags.    
      while(result.hasNext()) {
        // If error tag exists then image was not uploaded correctly.
        if (result.getLocalName() == 'Error') {
          return false;  
        }   
        result.next();
      }
    } catch(CalloutException e) {
      // If the callout exception was caused by the body being larger than 5MB then assume the files exists.
      if (e.getMessage() != 'Exceeded max size limit of 6000000') {
        return false;    
      }
    } catch (XmlException e) { 
      // If the response doesn't exist, or does but has no body then return false.
      if ((res == null) || (res != null && res.getBody() == null)) {
        return false;          
      }  
    } catch (Exception e) {
      // Any other errors that may occur assume the file doesn't exist.
      System.debug('-----> Error: ' + e.getMessage());
      return false;
    }
    return true;
  }
    
  /**
   * verifyFileUploaded
   * 
   * This function will verify that a file exists using the SOAP API. It checks the specified bucket using
   *   using a file prefix and checks the returns contents.
   * @author Darkis
   * @param String bucket The name of the bucket the file is located.
   * @param String filename The name of the file desired.
   */
  /* static Boolean verifyFileUploaded(String bucket, String filename) {
    Datetime now = Datetime.now();
    Integer maxNumberToList = 2; //Set the number of Objects to return for a specific Bucket
    //Limits the response to keys that begin with the indicated prefix. You can use prefixes to separate a bucket into different sets of keys in a way similar to how a file system uses folders. This is an optional argument.
    String Prefix = filename; 
    //Indicates where in the bucket to begin listing. The list includes only keys that occur alphabetically after marker. This is convenient for pagination: To get the next page of results use the last key of the current page as the marker. The most keys you'd like to see in the response body. The server might return less than this number of keys, but will not return more. This is an optional argument.
    String Marker = null; 
    //Causes keys that contain the same string between the prefix and the first occurrence of the delimiter to be rolled up into a single result element in the CommonPrefixes collection. These rolled-up keys are not returned elsewhere in the response. 
    String Delimiter = null; 
    // Get current credentials and create an instance of the S3 component.                  
    AWSKeys credentials = new AWSKeys('eec');
    S3.AmazonS3 as3 = new S3.AmazonS3(credentials.key,credentials.secret);  
    //This performs the Web Service call to Amazon S3 and retrieves all items meta data based on the given parameters.
    S3.ListBucketResult objectsForBucket = as3.ListBucket(bucket, Prefix, Marker,maxNumberToList, Delimiter,as3.key,now,as3.signature('ListBucket',now),as3.secret);
    // If the result exists and there is only one - 2 would mean a duplicate - then inform the user it was a success.
    if (objectsForBucket != null && objectsForBucket.Contents != null && objectsForBucket.Contents.size() == 1) {
      return true;
    }
    return false;
  }*/
  
  /**
   * generateTempS3Url 
   * 
   * This function will generate a temporary URL for a user to view a file marked as 'authticated-read'. The URL
   *   will only last as long as the configed value allows.  
   * @author Darkis
   * @param String bucket The bucket name where the file is located.
   * @param String filename The name of the file desired.
   */
  global static String generateTempS3Url(String bucket, String filename, AWSKeys creds) {
    // Special URL.
    String signedUrl = 'https://s3-us-gov-west-1.amazonaws.com';
    String filePath = '/' + bucket + '/' + filename;
    // Set the expiry on the url.  
    // TODO: Config the time in seconds desired.
    Datetime expireDatetime = System.now().addMinutes(15);
    String expires = String.valueOf(expireDatetime.getTime() / 1000);
    // Create the signature.
    String canonicalString = 'GET\n\n\n' + expires + '\n' + filePath;
    Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalString),blob.valueof(creds.secret_encrypted)); 
    String signature = EncodingUtil.base64Encode(mac); 
    // Patch together the signed url.
    signedUrl += filePath + '?AWSAccessKeyId=' + creds.key + '&Expires=' + expires + '&Signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');
    // Return the url to the user.
    return signedUrl;
  }

   /**
   * @Override
   * generateTempS3Url 
   * 
   * This function will generate a temporary URL for a user to view a file marked as 'authticated-read'. The URL
   *   will only last as long as the configed value allows. This version allows a credential to be passed in to bypass governer limits.
   * @author Darkis
   * @param AWSKeys awsConfig The configuration for EEC's AWS account. Needed to ensure we don't go over governer limits easily.
   * @param String bucket The bucket name where the file is located.
   * @param String filename The name of the file desired.
   */
  global static String generateTempS3Url(AWSKeys awsConfig, String bucket, String filename) {
    // Special URL.
    String signedUrl = AWS_Config__c.getInstance().S3_Endpoint_Url__c;
        String filePath = '/' + bucket + '/' + filename;
        // Set the expiry on the url.  
        // TODO: Config the time in seconds desired.
        Datetime expireDatetime = System.now().addMinutes(15);
        String expires = String.valueOf(expireDatetime.getTime() / 1000);
        // Create the signature.
        String canonicalString = 'GET\n\n\n' + expires + '\n' + filePath;
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalString),blob.valueof(awsConfig.secret_encrypted)); 
        String signature = EncodingUtil.base64Encode(mac); 
        // Patch together the signed url.
        signedUrl += filePath + '?AWSAccessKeyId=' + awsConfig.key + '&Expires=' + expires + '&Signature=' + EncodingUtil.urlEncode(signature, 'UTF-8');
        // Return the url to the user.
        return signedUrl;
  }
    
  global static void deleteFile(String bucket, String filename) {
    AWSKeys creds = new AWSKeys('eec');
    Datetime now = Datetime.now(); 
    S3.AmazonS3 s3 = new S3.AmazonS3(creds.key,creds.secret_encrypted);
    S3.Status deleteObjectReslt= s3.DeleteObject(bucket, filename, creds.key, now , s3.signature('DeleteObject', now), creds.secret_encrypted);
    System.debug('----> Delete Status: ' + deleteObjectReslt);
  }
    
  /**
   * FileTypeJsonWrapper
   * 
   * This wrapper class for the S3 File Type Json.
   * @author Darkis
   */
  global class FileTypeJsonWrapper {
    // Variables here
    public String filename {get;set;}
    public String type {get;set;} 
  }
    
  @RemoteAction
  global static List<Map<String,String>> generateMultiplePolicySignature(String bucket, String acl, String fileJson) {
    List<Map<String,String>> returnJson = new List<Map<String,String>>();  
    List<EEC_S3ComponentCtrl.FileTypeJsonWrapper> fileTypeWrapperList = (List<EEC_S3ComponentCtrl.FileTypeJsonWrapper>) JSON.deserialize(fileJson, List<EEC_S3ComponentCtrl.FileTypeJsonWrapper>.class);  
   
    for (EEC_S3ComponentCtrl.FileTypeJsonWrapper wrapper : fileTypeWrapperList) {
      returnJson.add(EEC_S3ComponentCtrl.generatePolicySignature(bucket, acl, wrapper.filename, wrapper.type, null)); 
    }    
    return returnJson;
  }  
}