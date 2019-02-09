// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
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

// Websocket (tail logs)
if ("WebSocket" in window && ((/experiments/.test(window.location.href)) && (/^((?!all).)*$/.test(window.location.href)))) {
  'use strict';

  var ws = null;

  function wsStart(){
    let messagesContainer = document.querySelector("#exp_log_messages")
    
    ws = new WebSocket(window.wsEndpoint + "/websocket?token=" + window.wsToken);
    
    ws.onopen = function(){
      console.log('ws connected');
    };
    
    ws.onmessage = function (evt) { 
      let messageItem = document.createElement("li");
      messageItem.innerText = evt.data;
      let list = document.getElementById("logsList");
      if (list.childElementCount >= 100) {
        var last = list.lastElementChild;
        list.removeChild(last);
        list.insertBefore(messageItem, list.childNodes[0]);
      } else {
        list.insertBefore(messageItem, list.childNodes[0]);
      }
    };
    
    ws.onclose = function(){
      console.log('ws closed');
    };
  }

  function wsCheck(){
    if(!ws || ws.readyState == 3) wsStart();
  }

  wsStart();

  // setInterval(wsCheck, 5000);
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