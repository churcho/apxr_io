defmodule ApxrIoWeb.Projects.ExperimentView do
  use ApxrIoWeb, :view

  def show_sort_info(nil), do: show_sort_info(:version)
  def show_sort_info(:version), do: "Sort: Version"
  def show_sort_info(:inserted_at), do: "Sort: Recently created"
  def show_sort_info(_param), do: nil

  def charts(data) do
    # raw("""
    #   <script type="text/javascript">
    #     window.onload = function(){  
    #       Highcharts.chart('fitness_vs_evals', {
    #         title: {
    #           text: 'Fitness (Max, Avg. Max, and Avg. Min) vs. Evaluations'
    #         },
    #         xAxis: {
    #           title: {
    #             text: 'Evaluations'
    #           }
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Fitness'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.fitness_vs_evals["morphology"]}'
    #         },
    #         legend: {
    #           layout: 'vertical',
    #           align: 'right',
    #           verticalAlign: 'middle'
    #         },
    #         plotOptions: {
    #           series: {
    #             label: {
    #               connectorAllowed: false
    #             },
    #             pointStart: 500,
    #             pointInterval: 500
    #           }
    #         },
    #         series: [{
    #           name: 'Max Fitness',
    #           data: #{inspect(data.fitness_vs_evals["max_fitness"])}
    #         }, {
    #           name: 'Avg. Max Fitness',
    #           data: #{inspect(data.fitness_vs_evals["maxavg_fitness"])}
    #         }, {
    #           name: 'Avg. Min Fitness',
    #           data: #{inspect(data.fitness_vs_evals["min_fintess"])}
    #         }],
    #         responsive: {
    #           rules: [{
    #             condition: {
    #               maxWidth: 500
    #             },
    #             chartOptions: {
    #               legend: {
    #                 layout: 'horizontal',
    #                 align: 'center',
    #                 verticalAlign: 'bottom'
    #               }
    #             }
    #           }]
    #         }
    #       });

    #       Highcharts.chart('val_fitness_vs_evals', {
    #         title: {
    #           text: 'Validation Fitness (Max, Min) vs. Evaluations'
    #         },
    #         xAxis: {
    #           title: {
    #             text: 'Evaluations'
    #           }
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Fitness'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.val_fitness_vs_evals["morphology"]}'
    #         },
    #         legend: {
    #           layout: 'vertical',
    #           align: 'right',
    #           verticalAlign: 'middle'
    #         },
    #         plotOptions: {
    #           series: {
    #             label: {
    #               connectorAllowed: false
    #             },
    #             pointStart: 500,
    #             pointInterval: 500
    #           }
    #         },
    #         series: [{
    #           name: 'Validation Max Fitness',
    #           data: #{inspect(data.val_fitness_vs_evals["validationmax_fitness"])}
    #         }, {
    #           name: 'Validation Min Fitness',
    #           data: #{inspect(data.val_fitness_vs_evals["validationmin_fitness"])}
    #         }],
    #         responsive: {
    #           rules: [{
    #             condition: {
    #               maxWidth: 500
    #             },
    #             chartOptions: {
    #               legend: {
    #                 layout: 'horizontal',
    #                 align: 'center',
    #                 verticalAlign: 'bottom'
    #               }
    #             }
    #           }]
    #         }
    #       });

    #       Highcharts.chart('specie_pop_turnover_vs_evals', {            
    #         title: {
    #           text: 'Specie Population Turnover Vs Evaluations'
    #         },
    #         xAxis: {
    #           title: {
    #             text: 'Evaluations'
    #           }
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Specie Population Turnover'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.specie_pop_turnover_vs_evals["morphology"]}'
    #         },
    #         legend: {
    #           layout: 'vertical',
    #           align: 'right',
    #           verticalAlign: 'middle'
    #         },
    #         plotOptions: {
    #           series: {
    #             label: {
    #               connectorAllowed: false
    #             },
    #             pointStart: 500,
    #             pointInterval: 500
    #           }
    #         },
    #         series: [{
    #           name: 'Specie-Population Turnover',
    #           data: #{inspect(data.specie_pop_turnover_vs_evals["specie_pop_turnover"])}
    #         }],
    #         responsive: {
    #           rules: [{
    #             condition: {
    #               maxWidth: 500
    #             },
    #             chartOptions: {
    #               legend: {
    #                 layout: 'horizontal',
    #                 align: 'center',
    #                 verticalAlign: 'bottom'
    #               }
    #             }
    #           }]
    #         }
    #       });
          
    #       Highcharts.chart('avg_val_fitness_vs_evals_std', {
    #         title: {
    #           text: 'Validation Fitness vs Evaluations'
    #         },
    #         xAxis: {
    #           type: 'Evaluations'
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Average Validation Fitness'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.avg_val_fitness_vs_evals_std["morphology"]}'
    #         },
    #         tooltip: {
    #           crosshairs: true,
    #           shared: true
    #         },
    #         legend: {},
    #         series: [{
    #           name: 'Validation Fitness',
    #           data: #{inspect(data.avg_val_fitness_vs_evals_std["avgs"])},
    #           zIndex: 1,
    #           marker: {
    #             fillColor: 'white',
    #             lineWidth: 2,
    #             lineColor: Highcharts.getOptions().colors[0]
    #           }
    #         },
    #         {
    #           name: 'Std. Dev',
    #           data: #{inspect(data.avg_val_fitness_vs_evals_std["std"])},
    #           type: 'arearange',
    #           lineWidth: 0,
    #           linkedTo: ':previous',
    #           color: Highcharts.getOptions().colors[0],
    #           fillOpacity: 0.3,
    #           zIndex: 0,
    #           marker: {
    #             enabled: false
    #           }
    #         }]
    #       });
           
    #       Highcharts.chart('avg_fitness_vs_evals_std', {
    #         title: {
    #           text: 'Fitness vs Evaluations'
    #         },
    #         xAxis: {
    #           type: 'Evaluations'
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Average Fitness'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.avg_fitness_vs_evals_std["morphology"]}'
    #         },
    #         tooltip: {
    #           crosshairs: true,
    #           shared: true
    #         },
    #         legend: {},
    #         series: [{
    #           name: 'Fitness',
    #           data: #{inspect(data.avg_fitness_vs_evals_std["avgs"])},
    #           zIndex: 1,
    #           marker: {
    #             fillColor: 'white',
    #             lineWidth: 2,
    #             lineColor: Highcharts.getOptions().colors[0]
    #           }
    #         },
    #         {
    #           name: 'Std. Dev',
    #           data: #{inspect(data.avg_fitness_vs_evals_std["std"])},
    #           type: 'arearange',
    #           lineWidth: 0,
    #           linkedTo: ':previous',
    #           color: Highcharts.getOptions().colors[0],
    #           fillOpacity: 0.3,
    #           zIndex: 0,
    #           marker: {
    #             enabled: false
    #           }
    #         }]
    #       });
        
    #       Highcharts.chart('avg_neurons_vs_evals_std', {
    #         title: {
    #           text: 'Neurons vs Evaluations'
    #         },
    #         xAxis: {
    #           type: 'Evaluations'
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Average Neurons'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.avg_neurons_vs_evals_std["morphology"]}'
    #         },
    #         tooltip: {
    #           crosshairs: true,
    #           shared: true
    #         },
    #         legend: {},
    #         series: [{
    #           name: 'Neurons',
    #           data: #{inspect(data.avg_neurons_vs_evals_std["avgs"])},
    #           zIndex: 1,
    #           marker: {
    #             fillColor: 'white',
    #             lineWidth: 2,
    #             lineColor: Highcharts.getOptions().colors[0]
    #           }
    #         },
    #         {
    #           name: 'Std. Dev',
    #           data: #{inspect(data.avg_neurons_vs_evals_std["std"])},
    #           type: 'arearange',
    #           lineWidth: 0,
    #           linkedTo: ':previous',
    #           color: Highcharts.getOptions().colors[0],
    #           fillOpacity: 0.3,
    #           zIndex: 0,
    #           marker: {
    #             enabled: false
    #           }
    #         }]
    #       });
         
    #       Highcharts.chart('avg_diversity_vs_evals_std', {
    #         title: {
    #           text: 'Diversity vs Evaluations'
    #         },
    #         xAxis: {
    #           type: 'Evaluations'
    #         },
    #         yAxis: {
    #           title: {
    #             text: 'Average Diversity'
    #           }
    #         },
    #         subtitle: {
    #           text: 'Morphology: #{data.avg_diversity_vs_evals_std["morphology"]}'
    #         },
    #         tooltip: {
    #           crosshairs: true,
    #           shared: true
    #         },
    #         legend: {},
    #         series: [{
    #           name: 'Diversity',
    #           data: #{inspect(data.avg_diversity_vs_evals_std["avgs"])},
    #           zIndex: 1,
    #           marker: {
    #             fillColor: 'white',
    #             lineWidth: 2,
    #             lineColor: Highcharts.getOptions().colors[0]
    #           }
    #         },
    #         {
    #           name: 'Std. Dev',
    #           data: #{inspect(data.avg_diversity_vs_evals_std["std"])},
    #           type: 'arearange',
    #           lineWidth: 0,
    #           linkedTo: ':previous',
    #           color: Highcharts.getOptions().colors[0],
    #           fillOpacity: 0.3,
    #           zIndex: 0,
    #           marker: {
    #             enabled: false
    #           }
    #         }]
    #       });
    #     };
    #   </script>
    # """)
  end
end
