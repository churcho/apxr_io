// Import jQuery
import $ from "jquery"

// Import CSS
import css from '../css/app.scss';

// Import dependencies
import "phoenix_html"

// Import local files
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// Highcharts
import Highcharts from "highcharts";
import HighchartsMore from "highcharts/highcharts-more";
window.Highcharts = Highcharts;
HighchartsMore(Highcharts);

// Clipboard
import Clipboard from "clipboard";
function addCopyButtonToCode(){
 // get all code elements
 var allCodeBlocksElements = $( "div.highlight pre" );

 // For each element, do the following steps
 allCodeBlocksElements.each(function(ii) {
 // define a unique id for this element and add it
 var currentId = "codeblock" + (ii + 1);
 $(this).attr('id', currentId);

 // create a button that's configured for clipboard.js
 // point it to the text that's in this code block
 // add the button just after the text in the code block w/ jquery
 var clipButton = '<button class="button is-light copybutton" data-clipboard-target="#' + currentId + '">copy</button>';
    $(this).after(clipButton);
 });

 // tell clipboard.js to look for clicks that match this query
 new Clipboard('.button');
}

// Experiment show
if ((/experiments/.test(window.location.href)) && (/^((?!all).)*$/.test(window.location.href))) {
  
  // Tabs  
  if (location.hash) {
    var tab_id = location.hash;
    $('.tabs li').removeClass('is-active');
    $('.tab-content').removeClass('is-active-tab');
    $('a[href=\'' + location.hash + '\']').parent().addClass('is-active');
    $(tab_id).addClass('is-active-tab');
  }
  
  var activeTab = localStorage.getItem('activeTab');
  if (activeTab) {
    
    var tab_id = activeTab;
    $('.tabs li').removeClass('is-active');
    $('.tab-content').removeClass('is-active-tab');
    $('a[href="' + activeTab + '"]').parent().addClass('is-active');
    $(tab_id).addClass('is-active-tab');
  }
  
  $('body').on('click', 'a[data-exp-tab=\'tab\']', function (e) {
    e.preventDefault()
  
    var tab_name = this.getAttribute('href')
    
    if (history.pushState) {
      history.pushState(null, null, tab_name)
    }
    else {
      location.hash = tab_name
    }
    
    localStorage.setItem('activeTab', tab_name)
  
    var tab_id = $(this).attr('data-exp-tab');
    $('.tabs li').removeClass('is-active');
    $('.tab-content').removeClass('is-active-tab');
    $(this).parent().addClass('is-active');
    $("#"+tab_id).addClass('is-active-tab');
  
    return false;
  });
  $(window).on('popstate', function () {
    var anchor = location.hash || $('a[data-exp-tab=\'tab\']').first().attr('href');
    
    var tab_id = $('a[href=\'' + anchor + '\']').attr('data-exp-tab');
    $('.tabs li').removeClass('is-active');
    $('.tab-content').removeClass('is-active-tab');
    $('a[href=\'' + anchor + '\']').parent().addClass('is-active');
    $("#"+tab_id).addClass('is-active-tab');
  });

  function refreshPage(){
    location.reload();
  }
  
  setInterval(refreshPage, 30000);
}

export default class App {
  constructor() {
    // Check for click events on the navbar burger icon
    $(".navbar-burger").click(function() {
      // Toggle the "is-active" class on both the "navbar-burger" and the "navbar-menu"
      $(".navbar-burger").toggleClass("is-active");
      $(".navbar-menu").toggleClass("is-active");
    });

    // Dismiss notification box
    $(".notification-delete").click(function(){
      $(".notification").hide();
    });

    // Dismiss notification box
    $(".notification-delete").click(function(){
      $(".notification").hide();
    });

    // Show dropdown menu
    $(".dropdown").click(function() {
      $(".dropdown").toggleClass("is-active");
    });

    // Switch tabs
    $('.tab').click(function(){
      var tab_id = $(this).attr('data-tab');

      $('.tabs li').removeClass('is-active');
      $('.tab-content').removeClass('is-active-tab');

      $(this).parent().addClass('is-active');
      $("#"+tab_id).addClass('is-active-tab');
    });

    // Modals
    var rootEl = document.documentElement;
    var $modals = getAll('.modal');
    var $modalButtons = getAll('.modal-button');
    var $modalCloses = getAll('.modal-background, .modal-close, .modal-card-head .delete, .modal-card-foot .button');

    if ($modalButtons.length > 0) {
      $modalButtons.forEach(function ($el) {
        $el.addEventListener('click', function () {
          var target = $el.dataset.target;
          openModal(target);
        });
      });
    }

    if ($modalCloses.length > 0) {
      $modalCloses.forEach(function ($el) {
        $el.addEventListener('click', function () {
          closeModals();
        });
      });
    }

    function openModal(target) {
      var $target = document.getElementById(target);
      rootEl.classList.add('is-clipped');
      $target.classList.add('is-active');
    }

    function closeModals() {
      rootEl.classList.remove('is-clipped');
      $modals.forEach(function ($el) {
        $el.classList.remove('is-active');
      });
    }

    document.addEventListener('keydown', function (event) {
      var e = event || window.event;
      if (e.keyCode === 27) {
        closeModals();
      }
    });

    function getAll(selector) {
      return Array.prototype.slice.call(document.querySelectorAll(selector), 0);
    };

    // Once the DOM is loaded for the page, attach clipboard buttons
    addCopyButtonToCode();
  }
}

new App()