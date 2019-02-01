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

    // Highlight syntax
    hljs.initHighlightingOnLoad()
  }
}

new App()