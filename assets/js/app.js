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

import socket from "./socket";

// Highcharts
import Highcharts from "highcharts";
import HighchartsMore from "highcharts/highcharts-more";
window.Highcharts = Highcharts;
HighchartsMore(Highcharts);

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
  }
}

new App()