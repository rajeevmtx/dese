/**
 * @version v1.3.1 - 10-08-2015
 * @author Darkis
 * @description
 *   This is a file upload directive to allow simple form POST uploads to S3 using
 *     form submits or ng-file-upload.
 */

(function() {
  'use strict';
  var s3FileUpload = angular.module('S3FileUpload', ['ngMaterial', 'ngFileUpload']);

  /**
   * @ngdoc directive
   * @name s3-file-upload
   * @module S3FileUpload
   *
   * @description
   * `s3-file-upload` directive is an AngularJS component for allow simple, reusable,
   *  and clean file upload input to a specified AWS Account with S3 access.
   * @param {string@} bucketName The name of the desired bucket.
   * @param {string@} key An AWS Access Key for the account in question.
   * @param {string@} acl The access agreement for the bucket.
   * @param {string@} redirectUrl The url you wish to direct the user to on success.
   * @param {string@} remoteFuncParams The remote action function needed to generate policy/sig data.
   * @param {string@} target The frame target if used.
   * @param {string@} previewEnabled This determines if an image preview is shown.
   * @param {string@} prefix A prefix for the filename to add a folder or set of folders.
   * @param {string@} directiveIndex An integer to inform the directive that it is being called multiple times.
   * @param {string@} multipleEnabled This will allow the input to allow multiple file selection.
   * @param {string@} descEnabled This will allow a description box for each file uploaded.
   * @param {string@} buttonText The text that is filled in the button.
   * @param {string@} endpointUrl The URL for the S3 uploads.
   * @usage
   * <hljs lang="html">
   *  <s3-File-Upload
   *    endpoint-url="https://s3.amazonaws.com/"
   *    filename="filename_1"
   *    bucket-name="test-bucket"
   *    key="***"
   *    acl="***"
   *    redirect-url="https://google.com/"
   *    remote-func-params="{!$RemoteAction.CtrlName.MethodName}"
   *    target="defaultFrame"
   *    preview-enabled="false"
   *    prefix="01234/"
   *    timestamp-enabled="false"
   *    directive-index="1"
   *    multiple-enabled="true"
   *    descEnabled="false"
   *    button-text="Add">
   *  </s3-File-Upload>
   * </hljs>
   */
  s3FileUpload.directive('s3FileUpload', ['$document',
    function($document) {
      return {
        scope: {
          filename: '@',
          bucketName: '@',
          key: '@',
          acl: '@',
          redirectUrl: '@',
          remoteFuncParams: '@',
          target: '@',
          previewEnabled: '@',
          timestampEnabled: '@',
          prefix: '@',
          directiveIndex: '@',
          buttonText: '@',
          multipleEnabled: '@',
          keepFilesEnabled: '@',
          descEnabled: '@',
          endpointUrl: '@'
        },
        restrict: 'E',
        link: function($scope, element, attrs) {
          // Broadcast receiver for upload function from Top level controller.
          $scope.$on('upload', function(event, data) {
            $scope.upload($scope.files);
          });
          // Default clear file name.
          var clearBroascastName = 'clearFiles';
          // Setup clear all functionality.
          $scope.$on(clearBroascastName, function(event, data) {
            $scope.clear();
          });
          // If there is an index on the directive then ensure that the clear is setup for multiple calls.
          if (typeof $scope.directiveIndex != 'undefined' && $scope.directiveIndex !== '') {
            clearBroascastName += '_' + $scope.directiveIndex;
            // Setup the $broadcast receiver for the specific directive in the root scope.
            $scope.$on(clearBroascastName, function(event, data) {
              $scope.clear();
            });
          }
        },
        controller: ['$scope', '$q', 'Upload', function($scope, $q, Upload) {
          $scope.files = [];
          $scope.uploadResults = [];
          $scope.fileDescriptions = {};
          $scope.fileDescriptionsMap = {};
          $scope.isSubmitted = false;

          $scope.$watch('files', function() {
            //console.log($scope.files);
          });

          $scope.$watch('fileDescriptions', function() {
            //console.log($scope.fileDescriptions);
          });

          $scope.clear = function() {
            $scope.files = [];
            $scope.fileDescriptions = {};
            $scope.fileDescriptionsMap = {};
            $scope.uploadResults = [];
            $scope.$apply();
          };

          /**
           * Upload
           *
           * This function will upload the form using ng-file-upload to S3.
           * @author Darkis
           * @param files Arr[] An array of all the current files to be uploaded.
           */
          $scope.upload = function(files) {
            $scope.isSubmitted = true;
			$scope.proxyURL = "https://cors-anywhere.herokuapp.com/";

            if (!$scope.descEnabled || $scope.s3form.$valid) {
              // If there are files to upload.
              if (files && files.length) {
                var fileNameTypeJsonArr = [];
                // Loop through files and get all names and types.
                for (var z = 0; z < files.length; z++) {
                  var file = files[z];
                  var filename = '';
                  // If the filename has been specified from the params then use it and add the correct extension.
                  if (!angular.isUndefined($scope.filename) && $scope.filename !== '') {
                    var fileNumber = '';
                    // If there are more than one file then append the file number to the filename.
                    if (files.length > 1) {
                      fileNumber = '_' + (z + 1);
                    }
                    filename = $scope.filename + fileNumber + '.' + file.name.split('.').pop();
                  } else {
                    filename = file.name;
                  }
                  // Remove any non alphanumeric characters excluding periods, dashes, and underscores.
                  filename = filename.replace(/[^a-z0-9_\-.]/gi, '_');
                  // Replace any double underscores with singles.
                  filename = filename.split('__').join('_');
                  // If timestamps have been enabled then attach one to the filename.
                  if ($scope.timestampEnabled) {
                    // Append a date/time stamp to the file name before the extension.
                    filename = filename.substring(0, filename.lastIndexOf(".")) + '_' + moment().format('YYYY-MM-DDThmmssSSZZ') + filename.substring(filename.lastIndexOf("."));
                  }
                  // If there is a prefix available then use it.
                  if (typeof $scope.prefix != "undefined" && $scope.prefix !== '') {
                    filename = $scope.prefix + filename;
                  }
                  // Create a json Object with the filename and type.
                  var jsonObj = {
                    "filename": filename,
                    "type": file.type
                  };
                  // Add the json to the array.
                  fileNameTypeJsonArr.push(jsonObj);
                  // Make a mapping of the file descriptions to their respective files.
                  $scope.fileDescriptionsMap[filename] = $scope.descEnabled && typeof $scope.fileDescriptions != "undefined" ? $scope.fileDescriptions[z] : "";
                }
                var fileTypeJson = JSON.stringify(fileNameTypeJsonArr);
                // Get all the policies and sig's.
                Visualforce.remoting.Manager.invokeAction(
                  $scope.remoteFuncParams,
                  $scope.bucketName,
                  $scope.acl,
                  fileTypeJson,
                  function(result, event) {
                    if (event.status) {
                      if (typeof result != "undefined") {
                        var promises = [];
                        // Loop through the files and create Upload promises.
                        for (var i = 0; i < files.length; i++) {
                          var fileKey = fileNameTypeJsonArr[i].filename;

                          // Add the promises to the promise list.
                          promises.push(Upload.upload({
                              url: $scope.proxyURL + $scope.endpointUrl + $scope.bucketName,
                              method: 'POST',
                              fields: {
                                key: fileKey,
                                AWSAccessKeyId: $scope.key,
                                policy: result[i].policy,
                                signature: result[i].signature,
                                acl: $scope.acl,
                                "Content-Type": fileNameTypeJsonArr[i].type,
                                "x-amz-server-side-encryption": "AES256",
                                filename: fileKey
                              },
                              file: files[i]
                          }).progress(function (evt) {
                              var progressPercentage = parseInt(100.0 * evt.loaded / evt.total);
                              //console.log('----> Upload Progress: ' + progressPercentage + '% ' + evt.config.file.name.toUpperCase());
                          }).success(function (data, status, headers, config) {
                              //console.log("====SUCCESS====");
                              // If descriptions are enabled then pass along the description for the given file.
                              try {
                                config.fields.description = $scope.descEnabled && typeof $scope.fileDescriptionsMap != "undefined" ? $scope.fileDescriptionsMap[config.fields.filename] : '';
                              } catch(e) {
                                config.fields.description = "";
                              }

                              var obj = {
                                status: true,
                                data: config.fields
                              };
                              $scope.uploadResults.push(obj);
                          }).error(function (data, status, headers, config) {
                              //console.log("====ERROR====");
                              var obj = {
                                status: false,
                                data: {}
                              };
                              $scope.uploadResults.push(obj);
                          }));
                        }

                        // Execute all the promises.
                        $q.all(promises)
                          .then(function() {
                            //console.log("----> Complete!");
                            $scope.$emit('uploadComplete', $scope.uploadResults);
                          }, function(error) {
                            //console.log("----> Error!");
                            //console.log(error);
                          });
                      }
                    } else if (event.type === "exception") {
                      //console.log("Exception: " + event.message + " at " + event.where);
                      $scope.$emit('uploadComplete', {'error': "Exception: " + event.message + " at " + event.where});
                    } else {
                      //console.log("Error: " + event.message);
                      $scope.$emit('uploadComplete', {'error': "Error: " + event.message});
                    }
                  },
                  {escapse: true}
                );
              } else {
                $scope.$emit('uploadComplete', {'error': 'No files to upload.'});
              }
            } else {
              $scope.isSubmitted = true;
              $scope.$apply();
              $scope.$emit('uploadComplete', {'error': 'Invalid Form.', 'message': 'Please ensure all form fields are completed.'});
            }
          };

          /**
           * Submit
           *
           * This function will use a standard submit to process a file to S3.
           * @author Darkis
           * @param form Obj This is an instance of the Angular form object.
           */
          $scope.submit = function(form) {
            // If the form is valid and not submitted.
            if (form.$valid && !form.$submitted) {
              Visualforce.remoting.Manager.invokeAction(
                $scope.remoteFuncParams,
                $scope.bucketName,
                $scope.acl,
                $scope.files[0].name,
                $scope.files[0].type,
                $scope.redirectUrl,
                function(result, event) {
                  if (event.status) {
                    if (typeof result.policy != "undefined" && typeof result.signature != "undefined") {
                      // Append a timestamp to the end of the filename.
                      var filename = $scope.files[0].name;
                      // Remove any non alphanumeric characters excluding periods, dashes, and underscores.
                      filename = filename.replace(/[^a-z0-9_\-.]/gi, '_');
                      // Replace any double underscores with singles.
                      filename = filename.split('__').join('_');
                      // Append a date/time stamp to the file name before the extension.
                      filename = filename.substring(0, filename.lastIndexOf(".")) + '_' + moment().format('YYYY-MM-DDThmmssZZ') + filename.substring(filename.lastIndexOf("."));
                      // Set the form inputs dynamically.
                      jQuery("input[name=policy]").val(result.policy);
                      jQuery("input[name=signature]").val(result.signature);
                      jQuery("input[name='Content-Type']").val($scope.files[0].type);
                      jQuery("input[name=key]").val(filename);
                      // Decode the URL from the result to ensure all & are not &amp;.
                      var url = decodeURIComponent(result.redirect);
                      url = url.replace(/&amp;/g, '&');
                      jQuery("input[name='success_action_redirect']").val(url);
                      jQuery('#s3form').submit();
                    }
                  } else if (event.type === "exception") {
                    console.log("Exception: " + event.message + " at " + event.where);
                  } else {
                    console.log("Error: " + event.message);
                  }
                },
                {escapse: true}
              );
            }
          };

          $scope.formSubmitted = function(form, key) {
            if (form['file-description-' + key].$touched || $scope.isSubmitted) {
              return true;
            }
            return false;
          };

          $scope.checkForImage = function(type) {
            if (typeof type != "undefined" && type.includes('image')) {
              if (typeof $scope.previewEnabled == "undefined" || $scope.previewEnabled != 'true') {
                return false;
              }
              return true;
            }
            return false;
          };
        }],
        template: function(element, attrs) {
          var multipleDirectiveAddition = '';
          var iframeTarget = '';
          var btnText = 'Select a File';

          if (typeof attrs.target != 'undefined' && attrs.target !== '') {
            iframeTarget = 'target="' + attrs.target + '"';
          }

          if (typeof attrs.directiveIndex != 'undefined' && attrs.directiveIndex !== '') {
            multipleDirectiveAddition = '_' + attrs.directiveIndex;
          }

          if (typeof attrs.buttonText != 'undefined' && attrs.buttonText !== '') {
            btnText = attrs.buttonText;
          }

          var template =
            '<ng-form id="s3form'+ multipleDirectiveAddition +'" name="s3form'+ multipleDirectiveAddition +'" action="https://s3.amazonaws.com/'+attrs.bucketName+'" method="post" enctype="multipart/form-data" '+ iframeTarget +'>' +
              '<input type="hidden"  name="key" />' +
              '<input type="hidden"  name="AWSAccessKeyId" value="'+attrs.key+'" />' +
              '<input type="hidden"  name="policy" ng-model="policy" />' +
              '<input type="hidden"  name="signature" ng-model="signature" />' +
              '<input type="hidden"  name="acl" value="'+attrs.acl+'" />' +
              '<input type="hidden"  name="Content-Type" />' +
              '<input type="hidden"  name="success_action_redirect" />' +
              '<input type="hidden"  name="x-amz-server-side-encryption" value="AES256" />' +
              '<div style="width: 100%;" layout="row" layout-align="center center">' +
                //'<img style="max-height: 300px;" ngf-src="files[0]" ngf-default-src="\'/thumb.jpg\'" ngf-accept="\'image/*\'" alt="No Image Available" ng-if="checkForImage(files[0].type)"/>' +
              '</div>' +
              '<div class="s3-input-container" layout="column" layout-lg="row" layout-gt-lg="row" layout-wrap>' +
                '<div class="s3-input-container-input" layout="row" layout-gt-sm="row" layout-align="center center">' +
                  '<div class="upload-button" layout="row" layout-align="center center">' +
                    //'<label class="md-raised md-button md-eec" md-ink-ripple for="file-input'+multipleDirectiveAddition+'" style="width: 98%;">' +
                    //  '<span>' + btnText + '</span>' +
                    //'</label>' +
                    //'<input id="file-input'+multipleDirectiveAddition+'" style="display:none;" type="file" size="50" name="file" required="true" ngf-select="true" ng-model="files" ngf-multiple="'+ (typeof attrs.multipleEnabled != undefined ? attrs.multipleEnabled : false)+ '" ngf-keep="'+ (typeof attrs.keepFilesEnabled != undefined ? attrs.keepFilesEnabled : false)+ '"/>' +
                    '<div class="md-raised md-button md-eec" style="width: 98%;" id="file-input'+multipleDirectiveAddition+'" name="file" ngf-select="true" ng-model="files" accept=".csv,.jpg,.png" ngf-multiple="'+ (typeof attrs.multipleEnabled != "undefined" ? attrs.multipleEnabled : false)+ '" ngf-keep="'+ (typeof attrs.keepFilesEnabled != "undefined" ? attrs.keepFilesEnabled : false)+ '">' +
                      '<span>' + btnText + '</span>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
                // If descriptions are disabled.
                '<div ng-if="!descEnabled" class="s3-input-container-labels" layout="row" layout-padding="true" layout-wrap flex="2" layout-align="start center" style="margin-left: 10px;">' +
                  '<label style="margin-right: 10px;">File:</label>' +
                  '<label ng-repeat="file in files">{{file.name}}<p ng-if="!$last" style="float: right; margin-right: 5px; margin-bottom: 0;">,</p></label>' +
                '</div>' +
                // If descriptions are enabled.
                '<div ng-if="descEnabled" class="s3-input-container-labels" layout="row" layout-padding="true" layout-wrap flex="100" layout-align="start center" style="margin-left: 10px;">' +
                  '<div ng-repeat="(key, file) in files" layout="row" layout-wrap flex="100">' +
                    '<div class="file-description-container" flex="100" layout="column">' +
                      '<label>{{file.name}}</label>' +
                      '<input type="text" placeholder="Enter a description" name="file-description-{{key}}" class="form-control" ng-model="fileDescriptions[key]" ng-maxlength="255" required/>' +
                      '<div ng-messages="s3form[\'file-description-\' + key].$error" ng-show="formSubmitted(s3form, key)">' +
                        '<div class="errorMsg" ng-message="required">A description is required.</div>' +
                        '<div class="errorMsg" ng-message="maxlength">The description must not exceed 255 characters.</div>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>' +
              '</div>' +
            '</ng-form>';
          return template;
        }
      };
    }
  ]);
})();
