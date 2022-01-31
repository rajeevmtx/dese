/**
 *
 * @version v1.0.0 - 2015-06-27
 * @author Darkis
 * @see https://github.com/Matesign/material-wizard
 * @description
 *   This directive/module is based off Material Wizard written by Matesign.
 */(function() {
  'use strict';
  var eecWizard = angular.module('eec.wizard', ['ngMaterial', 'ngAnimate']);

  /**
   * @ngdoc directive
   * @name eecWizard
   * @module eec.wizard
   *
   * @description
   * `eec-wizard` Angularjs wizard based on angular material inspired from material wizard
   * which is inspired by angular-wizard: https://github.com/mgonto/angular-wizard
   * Usually a form is to be defined inside this step. But a form can be defined for all the steps.
   * use the on onExit on mt-wz-step and the onFinish on the eec-wizard to control the data or api call submitted
   * the server
   * @param {string@} btn-progress-color color of the  circular progress that will be showed in the step circle
   * @param {string@} btn-bg-color normal button progress color
   * @param {string@} active-btn-bg-color selected button progress color
   * @param {string@} chevrons-always-visible "true" if you want disable/enable the chevrons instead of hide/show them
   * @usage
   * <hljs lang="html">
   *      <eec-wizard btn-progress-color="#D8D8D8"  btn-bg-color="#FAFAFA" active-btn-bg-color="#E9E9E9"  >
   *        <eec-wz-step title="Step 1" step-img="stepimage.svg" onExit="submitFormStep1">...</eec-wz-step>
   *        <eec-wz-step title="Step 2" step-img="stepimage.svg" onExit="submitFormStep2">...</eec-wz-step>
   *      <eec-wizard>
   * </hljs>
   */
  eecWizard.directive('eecWizard', ['$timeout', '$document','stepsArray',
    function (timer, $document,stepsArray) {
      return {
        scope: {
          //UI
          btnBgColor: '@',
          activeBtnBgColor: '@',
          inactiveBtnBgColor: '@',
          passedBtnBgColor: '@',
          btnProgressColor: '@',
          activeBtnProgressColor: '@',
          chevronsAlwaysVisible: '@',
          selectedIndex: '=',
          clicksEnabled: '@',
          //Actions
          onFinish: '&'
        },
        restrict: 'E',
        transclude: true,
        controller: ['$scope', function ($scope) {
          $scope.selectedIndex = 0;
          $scope.curentStepTitle = "";
          var steps = $scope.steps = [];
          var selectedSet = false;

          this.addStep = function (stepScope) {
            steps.push(stepScope);
            stepsArray.push(stepScope);
            stepScope.progresscircleStyle = {"background-color": $scope.btnProgressColor};
            var buttonStyle = $scope.btnBgColor;

            if ((stepScope.selected == true || stepScope.selected === 'true')) {
              buttonStyle = $scope.activeBtnBgColor;
            } else if ((stepScope.passed == true || stepScope.passed === 'true')) {
              buttonStyle = $scope.passedBtnBgColor;
            }

            stepScope.wizardBtnStyle = {"background-color": buttonStyle};
            // If the current step is selected then set the selectedIndex and set the step to active.
            if ((stepScope.selected == true || stepScope.selected === 'true') && !selectedSet) {
              selectedSet = true;
              $scope.selectedIndex = steps.length-1;
              setStepActive(stepScope, true);
            }
          };

          $scope.next = function () {
            if(steps[$scope.selectedIndex].onExit() !== false) {
              $scope.goto(Math.min($scope.selectedIndex + 1, steps.length - 1));
            }
          };

          $scope.previous = function () {
            $scope.goto(Math.max($scope.selectedIndex - 1, 0));
          };

          //Central function to select a step. All must go through it
          $scope.goto = function (stepNr) {
            if(steps[$scope.selectedIndex].onExit() !== false && $scope.clicksEnabled === "true") {
              setStepActive(steps[$scope.selectedIndex], false);
              $scope.selectedIndex = stepNr;
              setStepActive(steps[stepNr], true);
            }
          };

          /**
           * @param stepScope
           * @param active set to true if current step else false
           */
          function setStepActive(stepScope, active) {
            stepScope.selected = active;
            $scope.curentStepTitle = active ? stepScope.title : "";
            var buttonStyle = $scope.btnBgColor;

            if (active) {
              buttonStyle = $scope.activeBtnBgColor;
            } else if (stepScope.passed) {
              buttonStyle = $scope.passedBtnBgColor;
            }
            stepScope.wizardBtnStyle = {"background-color": buttonStyle};
          }
        }],
        template: function (element,attrs) {
          var chevronsStrategy = attrs.chevronsAlwaysVisible ? 'ng-disabled' : 'ng-hide';
          var template =
            '<div class="wizard" layout="column" layout-padding layout-align="center center">' +
            ' <div class="wizard-header col-lg-12" layout="column" layout-margin>' +
            '  <div class="wizard-header-step-list col-lg-12" layout="column" layout-margin>' +
            '   <div class="wizard-header-step" ng-repeat="step in steps" layout="row" layout-align="center center" ng-click="goto($index)">' +
            '    <div class="step-title" layout-margin flex="75">' +
            '      <h3 class="md-caption">{{step.title}}</h3>' +
            '    </div>' +
            '    <div class="step-button" flex="25" layout="column" layout-align="center center">' +
            '      <md-button class="md-fab wizard-button" aria-label="step button">' +
            '        <div class="circle-loader-wrap" ng-style="step.progresscircleStyle"><div class="circle-loader-wrap after" ng-style="step.wizardBtnStyle"></div></div>' +
            '        <div class="wizard-step-img">' +
            '          <i class="material-icons icon" ng-class="{\'passed\': step.passed == \'true\', \'selected\': step.selected == \'true\'}">{{step.stepImg}}</i>' +
            '        </div>' +
            '        <md-progress-circular md-mode="determinate" md-diameter="63" value="{{step.stepFill}}"></md-progress-circular>' +
            '      </md-button>' +
            '      <md-progress-linear md-mode="determinate" value="0" md-mode="buffer" md-buffer-value="100" class="md-primary wizard-progress-linear" ng-show="$index<steps.length-1"></md-progress-linear>' +
            '    </div>' +
            '   </div>' +
            '  </div>' +
            ' </div>' +
            ' <div layout="row" class="wizard-container" ng-transclude></div>' +
            '</div>';
          return template;
        },
        link: function (scope, element, attrs) {
          var updateProgressStyle = function () {
            var progressBars = $document[0].querySelectorAll("md-progress-linear .md-container");
            angular.forEach(progressBars, function (progressBar) {
              angular.element(progressBar).css('background-color', scope.btnProgressColor);
            });
          };
          timer(updateProgressStyle, 0);
        }
      };
    }
  ]);

  /**
   * @ngdoc directive
   * @name eecWzStep
   * @module eec.wizard
   *
   * @description
   * `eec-wz-step` Used to define a step inside the wizard. Usually a form is  be defined inside this step
   *
   * @param {string@} title Title of the step that will be displayed in the top left of wizard
   * @param {string@} step-img An svg image that will displayed in the step circle
   * @param {float@} step-fill Percent of the circular progress that will be showed in the step circle
   * @param {expression@} onExit function call on exit of the step, normally a form submit or server api call
   * @usage
   * <hljs lang="html">
   *    <eec-wz-step title="Step 1" step-img="stepimae.svg" onExit="submitForm"></eec-wz-step>
   * </hljs>
   */
  eecWizard.directive('eecWzStep', function () {
    return {
      require: '^eecWizard',
      restrict: 'E',
      transclude: true,
      replace: true,
      scope: {
        title: '@',
        stepImg: '@',
        stepFill: '@',
        selected: '@',
        passed: '@',
        onExit: '&'
      },
      template: '<div ng-show="selected" ng-transclude layout-fill> </div>',
      link: function (scope, element, attrs, wizardCtrl) {
        scope.stepFill = 0;
        scope.nextProgressValue = 0;
        wizardCtrl.addStep(scope);
      }
    };
  });

  /**
   * @ngdoc directive
   * @name stepFillPercent
   * @module eec.wizard
   *
   * @description
   * `step-fill-percent` Used to update the value of the attribute stepFill of the current step.
   * This will update the circular progress of thhe current step
   *
   * @param {string@} step-fill-percent how much the circular progress should be increased
   * @param {string=} step-index eecWzStep index
   * @usage
   * <hljs lang="html">
   *    <input   name="field1" ng-model="field1"  type="text" required step-fill-percent="30"  step-index="0">
   * </hljs>
   */
  eecWizard.directive('stepFillPercent',['stepsArray',
    function (stepsArray) {
      return {
        require: '?ngModel',
        restrict: 'A',
        link: function (scope, element, attrs,  ngModel, $rootScope) {
          var updated = false;
          //need to bypass the scope to avoid conflicting with other directives in the same level
          scope.stepIndex = scope.$eval(attrs.stepIndex);
          scope.stepFillPercent = scope.$eval(attrs.stepFillPercent);
          scope.$watch(attrs.ngModel, function () {
            if (ngModel.$valid ){
              if ( !updated){
                stepsArray[scope.stepIndex].stepFill =Math.min(parseInt(stepsArray[scope.stepIndex].stepFill)+  parseInt(scope.stepFillPercent),100);
                updated = true;
              }
            }else{
              if (updated){
                stepsArray[scope.stepIndex].stepFill = Math.max(parseInt(stepsArray[scope.stepIndex].stepFill) -parseInt( scope.stepFillPercent),0);
                updated = false;
              }
            }
          });
        }
      };
    }]);

  /**
   * TODO change to a service holding a list of wizards to avoid conflicts in case of more than one wizard
   */
  eecWizard.value('stepsArray', []);
})();
